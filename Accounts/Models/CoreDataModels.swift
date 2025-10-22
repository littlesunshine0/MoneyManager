import SwiftUI
import SwiftData
import Foundation

// MARK: - Core Financial Data Models

/// App User Profile and Preferences (SwiftData model)
@Model
public class AppUser {
    public var id: UUID
    public var firstName: String
    public var lastName: String
    public var email: String
    public var createdAt: Date
    public var updatedAt: Date
    
    // Preferences
    public var preferredCurrency: String
    public var dateFormat: String
    public var enableNotifications: Bool
    public var enableBiometricAuth: Bool
    public var enableDarkMode: Bool
    public var enableReducedMotion: Bool
    
    // Financial Settings
    public var defaultAccount: Account?
    public var budgetingEnabled: Bool
    public var savingsGoalsEnabled: Bool
    
    // Relationships
    public var accounts: [Account]
    public var categories: [Category]
    public var budgets: [Budget]
    public var goals: [Goal]
    
    public init(
        firstName: String,
        lastName: String,
        email: String,
        preferredCurrency: String = "USD"
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.preferredCurrency = preferredCurrency
        self.dateFormat = "MM/dd/yyyy"
        self.enableNotifications = true
        self.enableBiometricAuth = true
        self.enableDarkMode = false
        self.enableReducedMotion = false
        self.budgetingEnabled = true
        self.savingsGoalsEnabled = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.accounts = []
        self.categories = []
        self.budgets = []
        self.goals = []
    }
    
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    public var totalNetWorth: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
}

/// Financial Account (Bank, Credit Card, Investment, etc.)
@Model
public class Account {
    public var id: UUID
    public var name: String
    public var accountType: AccountType
    public var balance: Double
    public var currency: String
    public var accountNumber: String? // Masked for security
    public var institutionName: String?
    public var color: String // Hex color for UI
    public var isActive: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    // Relationships
    public var user: AppUser?
    public var transactions: [Transaction]
    
    public init(
        name: String,
        accountType: AccountType,
        balance: Double = 0.0,
        currency: String = "USD",
        accountNumber: String? = nil,
        institutionName: String? = nil,
        color: String = "#3882FF"
    ) {
        self.id = UUID()
        self.name = name
        self.accountType = accountType
        self.balance = balance
        self.currency = currency
        self.accountNumber = accountNumber
        self.institutionName = institutionName
        self.color = color
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.transactions = []
    }
    
    public var displayBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: balance)) ?? "$\(balance)"
    }
    
    public var maskedAccountNumber: String {
        guard let accountNumber = accountNumber else { return "****" }
        let suffix = String(accountNumber.suffix(4))
        return "****\(suffix)"
    }
    
    public func updateBalance() {
        let totalTransactions = transactions.reduce(0.0) { total, transaction in
            switch transaction.type {
            case .income, .deposit, .transferIn:
                return total + transaction.amount
            case .expense, .withdrawal, .transferOut:
                return total - transaction.amount
            case .transfer:
                // Neutral for generic transfer type (handled by specific in/out cases)
                return total
            }
        }
        self.balance = totalTransactions
        self.updatedAt = Date()
    }
}

/// Account Types
public enum AccountType: String, CaseIterable, Codable {
    case checking = "checking"
    case savings = "savings"
    case credit = "credit"
    case investment = "investment"
    case loan = "loan"
    case cash = "cash"
    case business = "business"
    
    public var displayName: String {
        switch self {
        case .checking: return "Checking"
        case .savings: return "Savings"
        case .credit: return "Credit Card"
        case .investment: return "Investment"
        case .loan: return "Loan"
        case .cash: return "Cash"
        case .business: return "Business"
        }
    }
    
    public var iconName: String {
        switch self {
        case .checking: return "creditcard"
        case .savings: return "banknote"
        case .credit: return "creditcard.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loan: return "percent"
        case .cash: return "banknote"
        case .business: return "building.2"
        }
    }
    
    public var defaultColor: String {
        switch self {
        case .checking: return "#3882FF"    // Primary blue
        case .savings: return "#14CC66"     // Success green
        case .credit: return "#F03D4F"      // Error red
        case .investment: return "#F5A500"  // Warning orange
        case .loan: return "#AB242F"        // Dark red
        case .cash: return "#54E894"        // Light green
        case .business: return "#1F56C2"    // Dark blue
        }
    }
}

/// Financial Transaction
@Model
public class Transaction {
    public var id: UUID
    public var amount: Double
    // Stored property cannot be named 'description' in @Model; use 'details' and bridge.
    public var details: String
    public var notes: String?
    public var date: Date
    public var type: TransactionType
    public var currency: String
    public var isRecurring: Bool
    public var recurringFrequency: RecurringFrequency?
    public var location: String?
    public var receiptImageURL: String?
    public var isCleared: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    // Relationships
    public var account: Account?
    public var category: Category?
    public var transferAccount: Account? // For transfers
    public var budget: Budget?
    
    public init(
        amount: Double,
        description: String,
        date: Date = Date(),
        type: TransactionType,
        currency: String = "USD",
        notes: String? = nil,
        location: String? = nil
    ) {
        self.id = UUID()
        self.amount = abs(amount) // Always store as positive
        self.details = description
        self.notes = notes
        self.date = date
        self.type = type
        self.currency = currency
        self.isRecurring = false
        self.location = location
        self.isCleared = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Computed property to preserve external API and usage
    public var description: String {
        get { details }
        set { details = newValue }
    }
    
    public var displayAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        let multiplier: Double = type.isExpense ? -1 : 1
        let displayValue = amount * multiplier
        
        return formatter.string(from: NSNumber(value: displayValue)) ?? "$\(displayValue)"
    }
    
    public var amountWithSign: Double {
        return type.isExpense ? -amount : amount
    }
    
    public var accessibilityDescription: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        let amountString = formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
        
        let typeString = type.isExpense ? "expense" : "income"
        let categoryString = category?.name ?? "uncategorized"
        
        return "\(typeString) of \(amountString) for \(description) in \(categoryString) category"
    }
}

/// Transaction Types
public enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"
    case transferIn = "transfer_in"
    case transferOut = "transfer_out"
    case deposit = "deposit"
    case withdrawal = "withdrawal"
    
    public var displayName: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        case .transfer: return "Transfer"
        case .transferIn: return "Transfer In"
        case .transferOut: return "Transfer Out"
        case .deposit: return "Deposit"
        case .withdrawal: return "Withdrawal"
        }
    }
    
    public var isExpense: Bool {
        switch self {
        case .expense, .withdrawal, .transferOut:
            return true
        case .income, .deposit, .transferIn, .transfer:
            return false
        }
    }
    
    public var iconName: String {
        switch self {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle"
        case .transferIn: return "arrow.down.circle"
        case .transferOut: return "arrow.up.circle"
        case .deposit: return "plus.circle.fill"
        case .withdrawal: return "minus.circle.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .income, .deposit, .transferIn:
            return "#14CC66" // Success green
        case .expense, .withdrawal, .transferOut:
            return "#F03D4F" // Error red
        case .transfer:
            return "#3882FF" // Primary blue
        }
    }
}

/// Recurring Frequency
public enum RecurringFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case semiannually = "semiannually"
    case annually = "annually"
    
    public var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biweekly: return "Bi-weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .semiannually: return "Semi-annually"
        case .annually: return "Annually"
        }
    }
    
    public var intervalDays: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        case .quarterly: return 90
        case .semiannually: return 180
        case .annually: return 365
        }
    }
}

/// Transaction Category
@Model
public class Category {
    public var id: UUID
    public var name: String
    public var color: String
    public var iconName: String
    public var parentCategory: Category?
    public var isDefault: Bool
    public var isActive: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    // Relationships
    public var user: AppUser?
    public var transactions: [Transaction]
    public var budgets: [Budget]
    public var subcategories: [Category]
    
    public init(
        name: String,
        color: String = "#3882FF",
        iconName: String = "folder.fill",
        isDefault: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.iconName = iconName
        self.isDefault = isDefault
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.transactions = []
        self.budgets = []
        self.subcategories = []
    }
    
    public var totalSpent: Double {
        let directSpent = transactions.reduce(0.0) { total, transaction in
            transaction.type.isExpense ? total + transaction.amount : total
        }
        
        let subcategorySpent = subcategories.reduce(0.0) { total, subcategory in
            total + subcategory.totalSpent
        }
        
        return directSpent + subcategorySpent
    }
    
    public var transactionCount: Int {
        return transactions.count + subcategories.reduce(0) { $0 + $1.transactionCount }
    }
}

/// Budget for spending control
@Model
public class Budget {
    public var id: UUID
    public var name: String
    public var amount: Double
    public var spent: Double
    public var period: BudgetPeriod
    public var startDate: Date
    public var endDate: Date
    public var isActive: Bool
    public var alertThreshold: Double // Percentage (0.0 to 1.0)
    public var color: String
    public var createdAt: Date
    public var updatedAt: Date
    
    // Relationships
    public var user: AppUser?
    public var category: Category?
    public var transactions: [Transaction]
    
    public init(
        name: String,
        amount: Double,
        period: BudgetPeriod = .monthly,
        alertThreshold: Double = 0.8,
        color: String = "#3882FF"
    ) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.spent = 0.0
        self.period = period
        self.alertThreshold = alertThreshold
        self.color = color
        self.isActive = true
               self.createdAt = Date()
        self.updatedAt = Date()
        self.transactions = []
        
        // Calculate date range based on period
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        self.startDate = start
        self.endDate = period.endDate(from: start)
    }
    
    public var remaining: Double {
        return amount - spent
    }
    
    public var percentageUsed: Double {
        guard amount > 0 else { return 0.0 }
        return min(spent / amount, 1.0)
    }
    
    public var isOverBudget: Bool {
        return spent > amount
    }
    
    public var shouldAlert: Bool {
        return percentageUsed >= alertThreshold
    }
    
    public var status: BudgetStatus {
        if isOverBudget {
            return .exceeded
        } else if shouldAlert {
            return .warning
        } else {
            return .onTrack
        }
    }
    
    public func updateSpent() {
        self.spent = transactions.reduce(0.0) { total, transaction in
            transaction.type.isExpense ? total + transaction.amount : total
        }
        self.updatedAt = Date()
    }
}

/// Budget Period
public enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
    case custom = "custom"
    
    public var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly: return "Yearly"
        case .custom: return "Custom"
        }
    }
    
    public func endDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: startDate) ?? startDate
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        case .custom:
            return startDate // Will be set manually
        }
    }
}

/// Budget Status
public enum BudgetStatus: String, CaseIterable, Codable {
    case onTrack = "on_track"
    case warning = "warning"
    case exceeded = "exceeded"
    
    public var displayName: String {
        switch self {
        case .onTrack: return "On Track"
        case .warning: return "Warning"
        case .exceeded: return "Exceeded"
        }
    }
    
    public var color: String {
        switch self {
        case .onTrack: return "#14CC66"     // Success green
        case .warning: return "#F5A500"     // Warning orange
        case .exceeded: return "#F03D4F"    // Error red
        }
    }
    
    public var iconName: String {
        switch self {
        case .onTrack: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .exceeded: return "exclamationmark.circle.fill"
        }
    }
}

/// Savings Goal
@Model
public class Goal {
    public var id: UUID
    public var name: String
    // Stored property cannot be named 'description' in @Model; use 'details' and bridge.
    public var details: String?
    public var targetAmount: Double
    public var currentAmount: Double
    public var targetDate: Date?
    public var isCompleted: Bool
    public var priority: GoalPriority
    public var color: String
    public var iconName: String
    public var createdAt: Date
    public var updatedAt: Date
    
    // Relationships
    public var user: AppUser?
    public var transactions: [Transaction] // Contributions to this goal
    
    public init(
        name: String,
        targetAmount: Double,
        description: String? = nil,
        targetDate: Date? = nil,
        priority: GoalPriority = .medium,
        color: String = "#14CC66",
        iconName: String = "target"
    ) {
        self.id = UUID()
        self.name = name
        self.details = description
        self.targetAmount = targetAmount
        self.currentAmount = 0.0
        self.targetDate = targetDate
        self.isCompleted = false
        self.priority = priority
        self.color = color
        self.iconName = iconName
        self.createdAt = Date()
        self.updatedAt = Date()
        self.transactions = []
    }
    
    // Computed property to preserve external API and usage
    public var description: String? {
        get { details }
        set { details = newValue }
    }
    
    public var remaining: Double {
        return max(targetAmount - currentAmount, 0.0)
    }
    
    public var percentageComplete: Double {
        guard targetAmount > 0 else { return 0.0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    public var isAchieved: Bool {
        return currentAmount >= targetAmount
    }
    
    public var estimatedMonthsToComplete: Int? {
        guard let targetDate = targetDate else { return nil }
        
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: Date(), to: targetDate).month ?? 0
        return max(months, 0)
    }
    
    public var requiredMonthlySavings: Double? {
        guard let months = estimatedMonthsToComplete, months > 0 else { return nil }
        return remaining / Double(months)
    }
    
    public func updateProgress() {
        self.currentAmount = transactions.reduce(0.0) { total, transaction in
            // Only count income/deposits as contributions
            !transaction.type.isExpense ? total + transaction.amount : total
        }
        
        if currentAmount >= targetAmount && !isCompleted {
            self.isCompleted = true
        }
        
        self.updatedAt = Date()
    }
}

/// Goal Priority
public enum GoalPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    public var color: String {
        switch self {
        case .low: return "#8090A3"         // Neutral gray
        case .medium: return "#3882FF"      // Primary blue
        case .high: return "#F5A500"        // Warning orange
        case .urgent: return "#F03D4F"      // Error red
        }
    }
    
    public var sortOrder: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

// MARK: - Default Data Creation
public extension AppUser {
    
    /// Creates default categories for a new user
    func createDefaultCategories() {
        let defaultCategories = [
            // Income Categories
            Category(name: "Salary", color: "#14CC66", iconName: "banknote", isDefault: true),
            Category(name: "Freelance", color: "#54E894", iconName: "person.badge.plus", isDefault: true),
            Category(name: "Investment Income", color: "#F5A500", iconName: "chart.line.uptrend.xyaxis", isDefault: true),
            Category(name: "Other Income", color: "#99F7BF", iconName: "plus.circle", isDefault: true),
            
            // Expense Categories
            Category(name: "Food & Dining", color: "#FF7885", iconName: "fork.knife", isDefault: true),
            Category(name: "Transportation", color: "#3882FF", iconName: "car", isDefault: true),
            Category(name: "Shopping", color: "#F5A500", iconName: "bag", isDefault: true),
            Category(name: "Entertainment", color: "#B0CFFF", iconName: "tv", isDefault: true),
            Category(name: "Utilities", color: "#FFC23D", iconName: "lightbulb", isDefault: true),
            Category(name: "Healthcare", color: "#F03D4F", iconName: "cross.case", isDefault: true),
            Category(name: "Education", color: "#78ABFF", iconName: "book", isDefault: true),
            Category(name: "Travel", color: "#FFB0B8", iconName: "airplane", isDefault: true),
            Category(name: "Housing", color: "#D18A00", iconName: "house", isDefault: true),
            Category(name: "Insurance", color: "#485566", iconName: "shield", isDefault: true),
            Category(name: "Personal Care", color: "#FF78AB", iconName: "person", isDefault: true),
            Category(name: "Gifts & Donations", color: "#B07000", iconName: "gift", isDefault: true),
            Category(name: "Business Expenses", color: "#1F56C2", iconName: "briefcase", isDefault: true),
            Category(name: "Other", color: "#8090A3", iconName: "ellipsis.circle", isDefault: true),
        ]
        
        self.categories.append(contentsOf: defaultCategories)
    }
    
    /// Creates a sample account for demo purposes
    func createSampleAccount() {
        let sampleAccount = Account(
            name: "Primary Checking",
            accountType: .checking,
            balance: 2500.00,
            institutionName: "Sample Bank",
            color: AccountType.checking.defaultColor
        )
        self.accounts.append(sampleAccount)
    }
    
    /// Creates sample data for demonstration
    func createSampleData() {
        createDefaultCategories()
        createSampleAccount()
        
        // Create sample budget
        let foodCategory = categories.first { $0.name == "Food & Dining" }
        let monthlyFoodBudget = Budget(
            name: "Monthly Food Budget",
            amount: 600.0,
            period: .monthly,
            alertThreshold: 0.8,
            color: "#FF7885"
        )
        monthlyFoodBudget.category = foodCategory
        budgets.append(monthlyFoodBudget)
        
        // Create sample goal
        let emergencyFund = Goal(
            name: "Emergency Fund",
            targetAmount: 10000.0,
            description: "3-6 months of expenses for emergencies",
            targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            priority: .high,
            color: "#14CC66",
            iconName: "shield.fill"
        )
        goals.append(emergencyFund)
    }
}

#if DEBUG
// MARK: - Preview Data Helper
public struct SampleDataGenerator {
    
    @MainActor
    public static func populatePreviewData(container: ModelContainer) {
        // Create sample user with data
        let sampleUser = AppUser(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com"
        )
        
        container.mainContext.insert(sampleUser)
        sampleUser.createSampleData()
        
        // Save the context
        try? container.mainContext.save()
    }
    
    public static func createSampleTransactions() -> [Transaction] {
        return [
            Transaction(amount: 4.50, description: "Coffee Shop", type: .expense),
            Transaction(amount: 125.00, description: "Grocery Store", type: .expense),
            Transaction(amount: 3000.00, description: "Salary Deposit", type: .income),
            Transaction(amount: 45.00, description: "Gas Station", type: .expense),
            Transaction(amount: 25.00, description: "Movie Tickets", type: .expense),
        ]
    }
}
#endif

import SwiftUI
import SwiftData
import Combine

// MARK: - Dashboard View Model
@MainActor
public class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var accounts: [Account] = []
    @Published public var recentTransactions: [Transaction] = []
    @Published public var budgets: [Budget] = []
    @Published public var goals: [Goal] = []
    @Published public var isLoading = false
    @Published public var selectedTimeframe: TimeFrame = .thisMonth
    @Published public var totalBalance: Double = 0.0
    @Published public var monthlyIncome: Double = 0.0
    @Published public var monthlyExpenses: Double = 0.0
    @Published public var budgetHealth: BudgetHealthStatus = .healthy
    
    // MARK: - Computed Properties
    public var netWorth: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    public var monthlyNetIncome: Double {
        monthlyIncome - monthlyExpenses
    }
    
    public var activeGoalsCount: Int {
        goals.filter { !$0.isCompleted }.count
    }
    
    public var overdueGoalsCount: Int {
        goals.filter { goal in
            guard let targetDate = goal.targetDate else { return false }
            return targetDate < Date() && !goal.isCompleted
        }.count
    }
    
    // MARK: - Methods
    public func refreshDashboard() async {
        isLoading = true
        
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await loadAccounts()
        await loadRecentTransactions()
        await loadBudgets()
        await loadGoals()
        calculateFinancialMetrics()
        
        isLoading = false
    }
    
    public func loadAccounts() async {
        // In real app, this would fetch from SwiftData
        accounts = createSampleAccounts()
        totalBalance = accounts.reduce(0) { $0 + $1.balance }
    }
    
    public func loadRecentTransactions() async {
        // In real app, this would fetch recent transactions
        recentTransactions = createSampleTransactions()
    }
    
    public func loadBudgets() async {
        // In real app, this would fetch active budgets
        budgets = createSampleBudgets()
        updateBudgetHealth()
    }
    
    public func loadGoals() async {
        // In real app, this would fetch active goals
        goals = createSampleGoals()
    }
    
    private func calculateFinancialMetrics() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let thisMonthTransactions = recentTransactions.filter { transaction in
            transaction.date >= startOfMonth
        }
        
        monthlyIncome = thisMonthTransactions
            .filter { !$0.type.isExpense }
            .reduce(0) { $0 + $1.amount }
        
        monthlyExpenses = thisMonthTransactions
            .filter { $0.type.isExpense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func updateBudgetHealth() {
        let exceededBudgets = budgets.filter { $0.isOverBudget }.count
        let warningBudgets = budgets.filter { $0.shouldAlert && !$0.isOverBudget }.count
        
        if exceededBudgets > 0 {
            budgetHealth = .critical
        } else if warningBudgets > 0 {
            budgetHealth = .warning
        } else {
            budgetHealth = .healthy
        }
    }
}

// MARK: - Helper Enums
public enum TimeFrame: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisQuarter = "This Quarter"
    case thisYear = "This Year"
}

public enum BudgetHealthStatus {
    case healthy
    case warning
    case critical
    
    var color: Color {
        switch self {
        case .healthy: return DesignTokens.Colors.success
        case .warning: return DesignTokens.Colors.warning
        case .critical: return DesignTokens.Colors.danger
        }
    }
    
    var iconName: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .healthy: return "All budgets on track"
        case .warning: return "Some budgets need attention"
        case .critical: return "Budgets exceeded"
        }
    }
}

// MARK: - Dashboard View
public struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DesignTokens.Spacing.lg) {
                    
                    // Header Section
                    DashboardHeader(viewModel: viewModel)
                        .slideInFromTop()
                    
                    // Quick Stats Cards
                    QuickStatsSection(viewModel: viewModel)
                        .slideInFromLeading(delay: 0.1)
                    
                    // Accounts Section
                    AccountsSection(accounts: viewModel.accounts)
                        .slideInFromTrailing(delay: 0.2)
                    
                    // Budget Overview
                    BudgetSection(budgets: viewModel.budgets, health: viewModel.budgetHealth)
                        .slideInFromLeading(delay: 0.3)
                    
                    // Goals Progress
                    GoalsSection(goals: viewModel.goals)
                        .slideInFromTrailing(delay: 0.4)
                    
                    // Recent Transactions
                    RecentTransactionsSection(transactions: viewModel.recentTransactions)
                        .slideInFromBottom(delay: 0.5)
                    
                    // Bottom spacing
                    Spacer()
                        .frame(height: DesignTokens.Spacing.xl)
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
            }
            .refreshable {
                await viewModel.refreshDashboard()
            }
            .navigationTitle("Dashboard")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refreshDashboard()
                        }
                    } label: {
                        Icon("arrow.clockwise", context: .toolbar)
                    }
                    .accessibleButton(title: "Refresh", action: "refreshes dashboard data")
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await viewModel.refreshDashboard()
                        }
                    } label: {
                        Icon("arrow.clockwise", context: .toolbar)
                    }
                    .accessibleButton(title: "Refresh", action: "refreshes dashboard data")
                }
                #endif
            }
        }
        .task {
            await viewModel.refreshDashboard()
        }
    }
}

// MARK: - Dashboard Header
private struct DashboardHeader: View {
    let viewModel: DashboardViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .medium) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                
                // Greeting and Date
                HStack {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Good \(greetingTime)")
                            .font(Typography.TextStyle.titleLarge)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        
                        Text(formattedDate)
                            .font(Typography.TextStyle.bodyMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    }
                    
                    Spacer()
                    
                    // Notification indicator
                    if viewModel.budgetHealth != .healthy {
                        Icon(viewModel.budgetHealth.iconName, context: .inline, color: viewModel.budgetHealth.color)
                            .accessibilityLabel(viewModel.budgetHealth.description)
                    }
                }
                
                Divider()
                    .background(themeManager.currentTheme.dividerColor)
                
                // Net Worth Display
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("Total Net Worth")
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    
                    Text(viewModel.netWorth, format: .currency(code: "USD"))
                        .currencyText(amount: viewModel.netWorth, style: .display)
                        .accessibleAmount(viewModel.netWorth, context: "total net worth")
                }
                
                // Monthly Overview
                HStack {
                    VStack(alignment: .leading) {
                        Text("This Month")
                            .font(Typography.TextStyle.labelSmall)
                            .foregroundColor(themeManager.currentTheme.textColorTertiary)
                        
                        Text(viewModel.monthlyNetIncome, format: .currency(code: "USD"))
                            .currencyText(
                                amount: viewModel.monthlyNetIncome,
                                style: .medium,
                                color: viewModel.monthlyNetIncome >= 0 ?
                                    DesignTokens.Colors.success : DesignTokens.Colors.danger
                            )
                    }
                    
                    Spacer()
                    
                    // Quick Actions
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        QuickActionButton(
                            icon: "plus.circle.fill",
                            color: DesignTokens.Colors.success
                        ) {
                            // Add income action
                        }
                        
                        QuickActionButton(
                            icon: "minus.circle.fill",
                            color: DesignTokens.Colors.danger
                        ) {
                            // Add expense action
                        }
                        
                        QuickActionButton(
                            icon: "arrow.left.arrow.right.circle.fill",
                            color: DesignTokens.Colors.primary500
                        ) {
                            // Transfer action
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Dashboard overview")
    }
    
    private var greetingTime: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Quick Action Button
private struct QuickActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    
    var body: some View {
        Button(action: action) {
            Icon(icon, context: .inline, color: color)
                .frame(width: 32, height: 32)
        }
        .buttonPress()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to perform action")
    }
    
    private var accessibilityLabel: String {
        switch icon {
        case "plus.circle.fill": return "Add income"
        case "minus.circle.fill": return "Add expense"
        case "arrow.left.arrow.right.circle.fill": return "Transfer money"
        default: return "Action button"
        }
    }
}

// MARK: - Quick Stats Section
private struct QuickStatsSection: View {
    let viewModel: DashboardViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Quick Stats")
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
            
            HStack(spacing: DesignTokens.Spacing.md) {
                DashboardStatCard(
                    title: "Income",
                    value: viewModel.monthlyIncome,
                    icon: "arrow.down.circle.fill",
                    color: DesignTokens.Colors.success
                )
                
                DashboardStatCard(
                    title: "Expenses",
                    value: viewModel.monthlyExpenses,
                    icon: "arrow.up.circle.fill",
                    color: DesignTokens.Colors.danger
                )
            }
        }
    }
}

// MARK: - Stat Card (renamed to avoid conflicts)
private struct DashboardStatCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .light) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    
                    Text(value, format: .currency(code: "USD"))
                        .currencyText(amount: value, style: .medium, color: color)
                }
                
                Spacer()
                
                Icon(icon, context: .inline, color: color)
            }
        }
        .cardHover()
        .accessibleAmount(value, context: title.lowercased())
    }
}

// MARK: - Accounts Section
private struct AccountsSection: View {
    let accounts: [Account]
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Accounts")
                    .font(Typography.TextStyle.headlineSmall)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Spacer()
                
                NavigationLink("View All") {
                    AccountsView()
                }
                .font(Typography.TextStyle.bodyMedium)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(accounts.prefix(5), id: \.id) { account in
                        AccountCard(account: account)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.xs)
            }
        }
    }
}

// MARK: - Account Card
private struct AccountCard: View {
    let account: Account
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .light) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack {
                    Icon(account.accountType.iconName, context: .inline, color: Color(hex: account.color))
                    
                    Spacer()
                    
                    Text(account.maskedAccountNumber)
                        .font(Typography.TextStyle.labelSmall)
                        .foregroundColor(themeManager.currentTheme.textColorTertiary)
                }
                
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(account.name)
                        .font(Typography.TextStyle.bodyMedium)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .lineLimit(1)
                    
                    if let institution = account.institutionName {
                        Text(institution)
                            .font(Typography.TextStyle.labelSmall)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                            .lineLimit(1)
                    }
                }
                
                Text(account.balance, format: .currency(code: account.currency))
                    .currencyText(amount: account.balance, style: .large)
                    .accessibleAmount(account.balance, context: "\(account.name) balance")
            }
        }
        .frame(width: 200)
        .cardHover()
        .accessibleAccountCard(
            accountName: account.name,
            balance: account.balance,
            accountType: account.accountType.displayName,
            onTap: {}
        )
    }
}

// MARK: - Budget Section
private struct BudgetSection: View {
    let budgets: [Budget]
    let health: BudgetHealthStatus
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Budgets")
                    .font(Typography.TextStyle.headlineSmall)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Spacer()
                
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Icon(health.iconName, context: .status, color: health.color)
                    Text(health.description)
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(health.color)
                }
            }
            
            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(budgets.prefix(3), id: \.id) { budget in
                    BudgetProgressCard(budget: budget)
                }
            }
            
            if budgets.count > 3 {
                NavigationLink("View All Budgets") {
                    BudgetsView()
                }
                .font(Typography.TextStyle.bodyMedium)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, DesignTokens.Spacing.xs)
            }
        }
    }
}

// MARK: - Budget Progress Card
private struct BudgetProgressCard: View {
    let budget: Budget
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .light) {
            VStack(spacing: DesignTokens.Spacing.sm) {
                HStack {
                    Text(budget.name)
                        .font(Typography.TextStyle.bodyMedium)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    
                    Spacer()
                    
                    Text("\(Int(budget.percentageUsed * 100))%")
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(Color(hex: budget.status.color))
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        CustomShapes.RoundedBar()
                            .fill(themeManager.currentTheme.backgroundColorTertiary)
                            .frame(height: 8)
                        
                        // Progress
                        CustomShapes.RoundedBar()
                            .fill(Color(hex: budget.status.color))
                            .frame(width: geometry.size.width * budget.percentageUsed, height: 8)
                            .animation(.easeInOut(duration: 0.5), value: budget.percentageUsed)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text(budget.spent, format: .currency(code: "USD"))
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    
                    Spacer()
                    
                    Text(budget.amount, format: .currency(code: "USD"))
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                }
            }
        }
        .accessibleBudgetProgress(spent: budget.spent, total: budget.amount, category: budget.name)
    }
}

// MARK: - Goals Section
private struct GoalsSection: View {
    let goals: [Goal]
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Goals")
                    .font(Typography.TextStyle.headlineSmall)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Spacer()
                
                NavigationLink("View All") {
                    GoalsView()
                }
                .font(Typography.TextStyle.bodyMedium)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(goals.prefix(3), id: \.id) { goal in
                        GoalCard(goal: goal)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.xs)
            }
        }
    }
}

// MARK: - Goal Card
private struct GoalCard: View {
    let goal: Goal
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .light) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack {
                    Icon(goal.iconName, context: .inline, color: Color(hex: goal.color))
                    
                    Spacer()
                    
                    Text("\(Int(goal.percentageComplete * 100))%")
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(Color(hex: goal.color))
                }
                
                Text(goal.name)
                    .font(Typography.TextStyle.bodyMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .lineLimit(2)
                
                ProgressIndicator(
                    progress: goal.percentageComplete,
                    size: 60,
                    thickness: 6,
                    color: Color(hex: goal.color)
                )
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(goal.currentAmount, format: .currency(code: "USD"))
                        .currencyText(amount: goal.currentAmount, style: .medium)
                    
                    Text("of \(goal.targetAmount, format: .currency(code: "USD"))")
                        .font(Typography.TextStyle.labelSmall)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                }
            }
        }
        .frame(width: 160)
        .cardHover()
        .accessibleGoalProgress(
            current: goal.currentAmount,
            target: goal.targetAmount,
            goalName: goal.name
        )
    }
}

// MARK: - Recent Transactions Section
private struct RecentTransactionsSection: View {
    let transactions: [Transaction]
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Recent Transactions")
                    .font(Typography.TextStyle.headlineSmall)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Spacer()
                
                NavigationLink("View All") {
                    TransactionsView()
                }
                .font(Typography.TextStyle.bodyMedium)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            FinancialCard(shadowLevel: .light) {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                        
                        if index < min(transactions.count, 5) - 1 {
                            Divider()
                                .padding(.leading, DesignTokens.Spacing.xl)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Transaction Row
private struct TransactionRow: View {
    let transaction: Transaction
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Transaction Icon
            Circle()
                .fill(Color(hex: transaction.type.color).opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Icon(
                        transaction.type.iconName,
                        context: .inline,
                        color: Color(hex: transaction.type.color)
                    )
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(transaction.description)
                    .font(Typography.TextStyle.bodyMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .lineLimit(1)
                
                HStack {
                    if let category = transaction.category {
                        Text(category.name)
                            .categoryLabel(category: category.name, color: Color(hex: category.color))
                    }
                    
                    Spacer()
                    
                    Text(transaction.date, format: .dateTime.month().day())
                        .font(Typography.TextStyle.labelSmall)
                        .foregroundColor(themeManager.currentTheme.textColorTertiary)
                }
            }
            
            Spacer()
            
            // Amount
            Text(transaction.displayAmount)
                .currencyText(
                    amount: transaction.amountWithSign,
                    style: .medium,
                    color: transaction.type.isExpense ?
                        DesignTokens.Colors.danger : DesignTokens.Colors.success
                )
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(transaction.accessibilityDescription)
    }
}

// MARK: - Sample Data Creation
extension DashboardViewModel {
    
    private func createSampleAccounts() -> [Account] {
        return [
            Account(
                name: "Primary Checking",
                accountType: .checking,
                balance: 2847.32,
                accountNumber: "1234",
                institutionName: "Chase Bank",
                color: AccountType.checking.defaultColor
            ),
            Account(
                name: "High Yield Savings",
                accountType: .savings,
                balance: 15420.78,
                accountNumber: "5678",
                institutionName: "Ally Bank",
                color: AccountType.savings.defaultColor
            ),
            Account(
                name: "Credit Card",
                accountType: .credit,
                balance: -1205.50,
                accountNumber: "9012",
                institutionName: "Capital One",
                color: AccountType.credit.defaultColor
            ),
            Account(
                name: "Investment Portfolio",
                accountType: .investment,
                balance: 48392.15,
                accountNumber: "3456",
                institutionName: "Vanguard",
                color: AccountType.investment.defaultColor
            )
        ]
    }
    
    private func createSampleTransactions() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            Transaction(
                amount: 4.50,
                description: "Starbucks Coffee",
                date: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                type: .expense
            ),
            Transaction(
                amount: 3200.00,
                description: "Salary Deposit",
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                type: .income
            ),
            Transaction(
                amount: 125.75,
                description: "Whole Foods Market",
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                type: .expense
            ),
            Transaction(
                amount: 45.20,
                description: "Shell Gas Station",
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                type: .expense
            ),
            Transaction(
                amount: 500.00,
                description: "Transfer to Savings",
                date: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
                type: .transfer
            )
        ]
    }
    
    private func createSampleBudgets() -> [Budget] {
        return [
            Budget(
                name: "Food & Dining",
                amount: 600.00,
                period: .monthly,
                alertThreshold: 0.8,
                color: "#FF7885"
            ).apply { budget in
                budget.spent = 450.75
            },
            Budget(
                name: "Transportation",
                amount: 400.00,
                period: .monthly,
                alertThreshold: 0.8,
                color: "#3882FF"
            ).apply { budget in
                budget.spent = 220.30
            },
            Budget(
                name: "Entertainment",
                amount: 200.00,
                period: .monthly,
                alertThreshold: 0.8,
                color: "#B0CFFF"
            ).apply { budget in
                budget.spent = 185.60
            }
        ]
    }
    
    private func createSampleGoals() -> [Goal] {
        return [
            Goal(
                name: "Emergency Fund",
                targetAmount: 10000.00,
                description: "3-6 months of expenses",
                targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                priority: .high,
                color: "#14CC66",
                iconName: "shield.fill"
            ).apply { goal in
                goal.currentAmount = 7500.00
            },
            Goal(
                name: "Vacation to Europe",
                targetAmount: 5000.00,
                description: "2 week trip to Europe",
                targetDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()),
                priority: .medium,
                color: "#F5A500",
                iconName: "airplane"
            ).apply { goal in
                goal.currentAmount = 2800.00
            },
            Goal(
                name: "New Car Down Payment",
                targetAmount: 8000.00,
                description: "Down payment for new car",
                targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
                priority: .medium,
                color: "#3882FF",
                iconName: "car.fill"
            ).apply { goal in
                goal.currentAmount = 3200.00
            }
        ]
    }
}

// MARK: - Helper Extensions
extension Budget {
    func apply(_ closure: (Budget) -> Void) -> Budget {
        closure(self)
        return self
    }
}

extension Goal {
    func apply(_ closure: (Goal) -> Void) -> Goal {
        closure(self)
        return self
    }
}

public struct BudgetsView: View {
    public var body: some View {
        Text("Budgets View")
            .navigationTitle("Budgets")
    }
}

public struct GoalsView: View {
    public var body: some View {
        Text("Goals View")
            .navigationTitle("Goals")
    }
}

public struct TransactionsView: View {
    public var body: some View {
        Text("Transactions View")
            .navigationTitle("Transactions")
    }
}

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ThemeManager())
            .environmentObject(AccessibilitySystem.AccessibilityManager())
    }
}
#endif

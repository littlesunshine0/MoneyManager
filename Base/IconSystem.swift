import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Icon System
public struct IconSystem {
    
    // MARK: - Icon Contexts (Based on your experience)
    public enum IconContext {
        case toolbar        // Navigation and action icons
        case pane          // Sidebar and panel icons  
        case dock          // Bottom navigation icons
        case app           // App icons and major features
        case inline        // Inline content icons
        case status        // Status and state indicators
    }
    
    // MARK: - Icon Weights (Nine weight system as requested)
    public enum IconWeight: String, CaseIterable {
        case ultraLight = "ultralight"
        case thin = "thin"
        case light = "light"
        case regular = "regular"
        case medium = "medium"
        case semibold = "semibold"
        case bold = "bold"
        case heavy = "heavy"
        case black = "black"
    }
    
    // MARK: - Icon Rendering Modes
    public enum IconMode {
        case monochrome     // Single color
        case hierarchical   // Multiple opacities of single color
        case palette        // Multiple colors
        case multicolor     // Full color (where available)
    }
    
    // MARK: - Financial Icon Categories
    public struct FinancialIcons {
        
        // MARK: - Account Types
        public struct Accounts {
            public static let checking = "creditcard"
            public static let savings = "banknote"
            public static let credit = "creditcard.fill"
            public static let investment = "chart.line.uptrend.xyaxis"
            public static let loan = "percent"
            public static let cash = "banknote"
            public static let business = "building.2"
        }
        
        // MARK: - Transaction Types
        public struct Transactions {
            public static let income = "arrow.down.circle.fill"
            public static let expense = "arrow.up.circle.fill"
            public static let transfer = "arrow.left.arrow.right.circle"
            public static let deposit = "plus.circle.fill"
            public static let withdrawal = "minus.circle.fill"
            public static let recurring = "repeat.circle"
            public static let split = "square.split.bottomrightquarter"
        }
        
        // MARK: - Categories (Expense Categories)
        public struct Categories {
            public static let food = "fork.knife"
            public static let groceries = "cart"
            public static let dining = "fork.knife.circle"
            public static let transportation = "car"
            public static let fuel = "fuelpump"
            public static let shopping = "bag"
            public static let entertainment = "tv"
            public static let utilities = "lightbulb"
            public static let healthcare = "cross.case"
            public static let education = "book"
            public static let travel = "airplane"
            public static let housing = "house"
            public static let insurance = "shield"
            public static let taxes = "doc.text"
            public static let investments = "chart.pie"
            public static let gifts = "gift"
            public static let personal = "person"
            public static let business = "briefcase"
            public static let other = "ellipsis.circle"
        }
        
        // MARK: - Budget & Goals
        public struct BudgetsGoals {
            public static let budget = "chart.bar"
            public static let goal = "target"
            public static let progress = "chart.pie.fill"
            public static let achievement = "rosette"
            public static let warning = "exclamationmark.triangle"
            public static let success = "checkmark.circle.fill"
            public static let exceeded = "exclamationmark.circle.fill"
        }
        
        // MARK: - Reports & Analytics
        public struct Reports {
            public static let overview = "chart.xyaxis.line"
            public static let trends = "chart.line.uptrend.xyaxis"
            public static let comparison = "chart.bar.xaxis"
            public static let breakdown = "chart.pie"
            public static let export = "square.and.arrow.up"
            public static let calendar = "calendar"
            public static let filter = "line.horizontal.3.decrease.circle"
        }
    }
    
    // MARK: - Interface Icons (Contextual Organization)
    public struct InterfaceIcons {
        
        // MARK: - Toolbar Icons (20pt)
        public struct Toolbar {
            public static let add = "plus"
            public static let edit = "pencil"
            public static let delete = "trash"
            public static let share = "square.and.arrow.up"
            public static let search = "magnifyingglass"
            public static let filter = "line.horizontal.3.decrease.circle"
            public static let sort = "arrow.up.arrow.down"
            public static let more = "ellipsis.circle"
            public static let close = "xmark"
            public static let back = "chevron.left"
            public static let forward = "chevron.right"
        }
        
        // MARK: - Pane Icons (16pt - Sidebar/Panel)
        public struct Pane {
            public static let dashboard = "rectangle.grid.1x2"
            public static let accounts = "creditcard.2"
            public static let transactions = "list.bullet.rectangle"
            public static let budgets = "chart.bar.fill"
            public static let goals = "target"
            public static let reports = "chart.xyaxis.line"
            public static let categories = "folder.fill"
            public static let settings = "gearshape.fill"
            public static let help = "questionmark.circle.fill"
            public static let profile = "person.circle.fill"
        }
        
        // MARK: - Dock Icons (24pt - Bottom Navigation)
        public struct Dock {
            public static let home = "house.fill"
            public static let accounts = "creditcard.fill"
            public static let transactions = "list.bullet.rectangle.fill"
            public static let budgets = "chart.bar.fill"
            public static let more = "ellipsis.circle.fill"
        }
        
        // MARK: - App Icons (32pt+ - Major Features)
        public struct App {
            public static let moneyManager = "dollarsign.circle.fill"
            public static let dashboard = "chart.pie.fill"
            public static let wallet = "wallet.pass.fill"
            public static let bank = "building.columns.fill"
            public static let calculator = "calculator.fill"
            public static let receipt = "receipt.fill"
        }
    }
    
    // MARK: - System Status Icons
    public struct StatusIcons {
        public static let success = "checkmark.circle.fill"
        public static let warning = "exclamationmark.triangle.fill"
        public static let error = "xmark.circle.fill"
        public static let info = "info.circle.fill"
        public static let loading = "clock.fill"
        public static let sync = "arrow.clockwise.circle.fill"
        public static let offline = "wifi.slash"
        public static let secure = "lock.fill"
        public static let biometric = "faceid"
    }
}

// MARK: - Icon Component
public struct Icon: View {
    private let symbolName: String
    private let context: IconSystem.IconContext
    private let weight: IconSystem.IconWeight
    private let mode: IconSystem.IconMode
    private let color: Color?
    private let customSize: CGFloat?
    
    public init(
        _ symbolName: String,
        context: IconSystem.IconContext = .inline,
        weight: IconSystem.IconWeight = .regular,
        mode: IconSystem.IconMode = .monochrome,
        color: Color? = nil,
        size: CGFloat? = nil
    ) {
        self.symbolName = symbolName
        self.context = context
        self.weight = weight
        self.mode = mode
        self.color = color
        self.customSize = size
    }
    
    public var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: iconSize, weight: fontWeight))
            .symbolRenderingMode(renderingMode)
            .foregroundColor(iconColor)
            .frame(width: iconSize, height: iconSize)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
    }
    
    private var iconSize: CGFloat {
        if let customSize = customSize {
            return customSize
        }
        
        switch context {
        case .toolbar:
            return DesignTokens.IconSize.toolbar
        case .pane:
            return DesignTokens.IconSize.pane
        case .dock:
            return DesignTokens.IconSize.dock
        case .app:
            return DesignTokens.IconSize.app
        case .inline:
            return DesignTokens.IconSize.md
        case .status:
            return DesignTokens.IconSize.sm
        }
    }
    
    private var fontWeight: Font.Weight {
        switch weight {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
    
    private var renderingMode: SymbolRenderingMode {
        switch mode {
        case .monochrome: return .monochrome
        case .hierarchical: return .hierarchical
        case .palette: return .palette
        case .multicolor: return .multicolor
        }
    }
    
    private var iconColor: Color {
        if let color = color {
            return color
        }
        
        // Default contextual colors
        switch context {
        case .toolbar, .pane, .dock:
            return DesignTokens.Colors.textSecondary
        case .app:
            return DesignTokens.Colors.primary500
        case .inline:
            return DesignTokens.Colors.textTertiary
        case .status:
            return DesignTokens.Colors.textSecondary
        }
    }
    
    private var accessibilityLabel: String {
        // Convert symbol name to human-readable label
        symbolName
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

// MARK: - Financial Icon Components
public struct FinancialIcon: View {
    private let type: FinancialIconType
    private let context: IconSystem.IconContext
    private let weight: IconSystem.IconWeight
    private let color: Color?
    
    public init(
        _ type: FinancialIconType,
        context: IconSystem.IconContext = .inline,
        weight: IconSystem.IconWeight = .regular,
        color: Color? = nil
    ) {
        self.type = type
        self.context = context
        self.weight = weight
        self.color = color
    }
    
    public var body: some View {
        Icon(
            type.symbolName,
            context: context,
            weight: weight,
            color: color ?? type.defaultColor
        )
    }
}

// MARK: - Financial Icon Types
public enum FinancialIconType {
    // Account types
    case checking, savings, credit, investment, loan, cash, business
    
    // Transaction types
    case income, expense, transfer, deposit, withdrawal, recurring, split
    
    // Categories
    case food, groceries, dining, transportation, fuel, shopping
    case entertainment, utilities, healthcare, education, travel
    case housing, insurance, taxes, investments, gifts, personal, other
    
    // Budget & Goals
    case budget, goal, progress, achievement, warning, success, exceeded
    
    // Reports
    case overview, trends, comparison, breakdown, export, calendar, filter
    
    var symbolName: String {
        switch self {
        // Accounts
        case .checking: return IconSystem.FinancialIcons.Accounts.checking
        case .savings: return IconSystem.FinancialIcons.Accounts.savings
        case .credit: return IconSystem.FinancialIcons.Accounts.credit
        case .investment: return IconSystem.FinancialIcons.Accounts.investment
        case .loan: return IconSystem.FinancialIcons.Accounts.loan
        case .cash: return IconSystem.FinancialIcons.Accounts.cash
        case .business: return IconSystem.FinancialIcons.Accounts.business
            
        // Transactions
        case .income: return IconSystem.FinancialIcons.Transactions.income
        case .expense: return IconSystem.FinancialIcons.Transactions.expense
        case .transfer: return IconSystem.FinancialIcons.Transactions.transfer
        case .deposit: return IconSystem.FinancialIcons.Transactions.deposit
        case .withdrawal: return IconSystem.FinancialIcons.Transactions.withdrawal
        case .recurring: return IconSystem.FinancialIcons.Transactions.recurring
        case .split: return IconSystem.FinancialIcons.Transactions.split
            
        // Categories
        case .food: return IconSystem.FinancialIcons.Categories.food
        case .groceries: return IconSystem.FinancialIcons.Categories.groceries
        case .dining: return IconSystem.FinancialIcons.Categories.dining
        case .transportation: return IconSystem.FinancialIcons.Categories.transportation
        case .fuel: return IconSystem.FinancialIcons.Categories.fuel
        case .shopping: return IconSystem.FinancialIcons.Categories.shopping
        case .entertainment: return IconSystem.FinancialIcons.Categories.entertainment
        case .utilities: return IconSystem.FinancialIcons.Categories.utilities
        case .healthcare: return IconSystem.FinancialIcons.Categories.healthcare
        case .education: return IconSystem.FinancialIcons.Categories.education
        case .travel: return IconSystem.FinancialIcons.Categories.travel
        case .housing: return IconSystem.FinancialIcons.Categories.housing
        case .insurance: return IconSystem.FinancialIcons.Categories.insurance
        case .taxes: return IconSystem.FinancialIcons.Categories.taxes
        case .investments: return IconSystem.FinancialIcons.Categories.investments
        case .gifts: return IconSystem.FinancialIcons.Categories.gifts
        case .personal: return IconSystem.FinancialIcons.Categories.personal
        case .other: return IconSystem.FinancialIcons.Categories.other
            
        // Budget & Goals
        case .budget: return IconSystem.FinancialIcons.BudgetsGoals.budget
        case .goal: return IconSystem.FinancialIcons.BudgetsGoals.goal
        case .progress: return IconSystem.FinancialIcons.BudgetsGoals.progress
        case .achievement: return IconSystem.FinancialIcons.BudgetsGoals.achievement
        case .warning: return IconSystem.FinancialIcons.BudgetsGoals.warning
        case .success: return IconSystem.FinancialIcons.BudgetsGoals.success
        case .exceeded: return IconSystem.FinancialIcons.BudgetsGoals.exceeded
            
        // Reports
        case .overview: return IconSystem.FinancialIcons.Reports.overview
        case .trends: return IconSystem.FinancialIcons.Reports.trends
        case .comparison: return IconSystem.FinancialIcons.Reports.comparison
        case .breakdown: return IconSystem.FinancialIcons.Reports.breakdown
        case .export: return IconSystem.FinancialIcons.Reports.export
        case .calendar: return IconSystem.FinancialIcons.Reports.calendar
        case .filter: return IconSystem.FinancialIcons.Reports.filter
        }
    }
    
    var defaultColor: Color {
        switch self {
        case .income, .deposit, .success:
            return DesignTokens.Colors.success
        case .expense, .withdrawal, .exceeded:
            return DesignTokens.Colors.danger
        case .transfer:
            return DesignTokens.Colors.info
        case .warning:
            return DesignTokens.Colors.warning
        case .achievement:
            return DesignTokens.Colors.tertiary500
        default:
            return DesignTokens.Colors.textSecondary
        }
    }
}

// MARK: - Icon Grid Component (For your copy-paste friendly catalog)
public struct IconCatalog: View {
    private let context: IconSystem.IconContext
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    public init(context: IconSystem.IconContext = .inline) {
        self.context = context
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                
                // Financial Icons Section
                iconSection(title: "Financial Icons", icons: financialIcons)
                
                // Interface Icons Section
                iconSection(title: "Interface Icons", icons: interfaceIcons)
                
                // Status Icons Section
                iconSection(title: "Status Icons", icons: statusIcons)
            }
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle("Icon Catalog")
    }
    
    private func iconSection(title: String, icons: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(title)
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            LazyVGrid(columns: columns, spacing: DesignTokens.Spacing.md) {
                ForEach(icons, id: \.0) { iconName, symbolName in
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Icon(symbolName, context: context)
                            .padding(DesignTokens.Spacing.sm)
                            .background(DesignTokens.Colors.backgroundSecondary)
                            .cornerRadius(DesignTokens.BorderRadius.md)
                        
                        Text(iconName)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(DesignTokens.Colors.textTertiary)
                    }
                    .onTapGesture {
                        // Copy symbol name to clipboard
                        #if canImport(UIKit)
                        UIPasteboard.general.string = symbolName
                        #elseif canImport(AppKit)
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(symbolName, forType: .string)
                        #endif
                    }
                }
            }
        }
    }
    
    private var financialIcons: [(String, String)] {
        [
            ("Checking", IconSystem.FinancialIcons.Accounts.checking),
            ("Savings", IconSystem.FinancialIcons.Accounts.savings),
            ("Credit", IconSystem.FinancialIcons.Accounts.credit),
            ("Investment", IconSystem.FinancialIcons.Accounts.investment),
            ("Income", IconSystem.FinancialIcons.Transactions.income),
            ("Expense", IconSystem.FinancialIcons.Transactions.expense),
            ("Transfer", IconSystem.FinancialIcons.Transactions.transfer),
            ("Food", IconSystem.FinancialIcons.Categories.food),
            ("Transportation", IconSystem.FinancialIcons.Categories.transportation),
            ("Shopping", IconSystem.FinancialIcons.Categories.shopping),
            ("Entertainment", IconSystem.FinancialIcons.Categories.entertainment),
            ("Budget", IconSystem.FinancialIcons.BudgetsGoals.budget),
        ]
    }
    
    private var interfaceIcons: [(String, String)] {
        [
            ("Add", IconSystem.InterfaceIcons.Toolbar.add),
            ("Edit", IconSystem.InterfaceIcons.Toolbar.edit),
            ("Delete", IconSystem.InterfaceIcons.Toolbar.delete),
            ("Search", IconSystem.InterfaceIcons.Toolbar.search),
            ("Dashboard", IconSystem.InterfaceIcons.Pane.dashboard),
            ("Accounts", IconSystem.InterfaceIcons.Pane.accounts),
            ("Transactions", IconSystem.InterfaceIcons.Pane.transactions),
            ("Settings", IconSystem.InterfaceIcons.Pane.settings),
        ]
    }
    
    private var statusIcons: [(String, String)] {
        [
            ("Success", IconSystem.StatusIcons.success),
            ("Warning", IconSystem.StatusIcons.warning),
            ("Error", IconSystem.StatusIcons.error),
            ("Info", IconSystem.StatusIcons.info),
            ("Loading", IconSystem.StatusIcons.loading),
            ("Sync", IconSystem.StatusIcons.sync),
            ("Secure", IconSystem.StatusIcons.secure),
            ("Biometric", IconSystem.StatusIcons.biometric),
        ]
    }
}

// MARK: - SwiftUI Extensions
extension View {
    public func icon(_ symbolName: String, context: IconSystem.IconContext = .inline) -> some View {
        HStack {
            Icon(symbolName, context: context)
            self
        }
    }
    
    public func financialIcon(_ type: FinancialIconType, context: IconSystem.IconContext = .inline) -> some View {
        HStack {
            FinancialIcon(type, context: context)
            self
        }
    }
}

#if DEBUG
// MARK: - Icon System Preview
struct IconSystem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Icon catalog preview
            IconCatalog(context: .inline)
                .previewDisplayName("Icon Catalog")
            
            // Context sizes preview
            IconContextPreview()
                .previewDisplayName("Icon Contexts")
        }
    }
}

struct IconContextPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            
            contextSection("Toolbar (20pt)", context: .toolbar)
            contextSection("Pane (16pt)", context: .pane)
            contextSection("Dock (24pt)", context: .dock)
            contextSection("App (32pt)", context: .app)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Icon Contexts")
    }
    
    private func contextSection(_ title: String, context: IconSystem.IconContext) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.headline)
            
            HStack(spacing: DesignTokens.Spacing.md) {
                Icon("house.fill", context: context)
                Icon("creditcard.fill", context: context)
                Icon("chart.bar.fill", context: context)
                Icon("gearshape.fill", context: context)
                Spacer()
            }
        }
    }
}
#endif

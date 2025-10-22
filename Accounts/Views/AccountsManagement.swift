import SwiftUI
import SwiftData
import Combine

// MARK: - Accounts View Model
@MainActor
public class AccountsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var accounts: [Account] = []
    @Published public var selectedAccount: Account?
    @Published public var isLoading = false
    @Published public var searchText = ""
    @Published public var selectedAccountType: AccountType? = nil
    @Published public var sortOption: AccountSortOption = .balance
    @Published public var showInactiveAccounts = false
    @Published public var totalAssets: Double = 0.0
    @Published public var totalLiabilities: Double = 0.0
    @Published public var netWorth: Double = 0.0
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    public var filteredAccounts: [Account] {
        var filtered = accounts
        
        // Filter by active status
        if !showInactiveAccounts {
            filtered = filtered.filter { $0.isActive }
        }
        
        // Filter by account type
        if let accountType = selectedAccountType {
            filtered = filtered.filter { $0.accountType == accountType }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { account in
                account.name.localizedCaseInsensitiveContains(searchText) ||
                account.institutionName?.localizedCaseInsensitiveContains(searchText) == true ||
                account.accountType.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort accounts
        return filtered.sorted { first, second in
            switch sortOption {
            case .name:
                return first.name < second.name
            case .balance:
                return first.balance > second.balance
            case .accountType:
                return first.accountType.rawValue < second.accountType.rawValue
            case .dateCreated:
                return first.createdAt > second.createdAt
            case .institution:
                let firstName = first.institutionName ?? ""
                let secondName = second.institutionName ?? ""
                return firstName < secondName
            }
        }
    }
    
    public var assetAccounts: [Account] {
        accounts.filter { account in
            switch account.accountType {
            case .checking, .savings, .investment, .cash:
                return account.balance >= 0
            default:
                return false
            }
        }
    }
    
    public var liabilityAccounts: [Account] {
        accounts.filter { account in
            switch account.accountType {
            case .credit, .loan:
                return true
            case .checking, .savings, .investment, .cash:
                return account.balance < 0
            default:
                return false
            }
        }
    }
    
    public var accountTypeGroups: [AccountTypeGroup] {
        let grouped = Dictionary(grouping: filteredAccounts) { $0.accountType }
        return AccountType.allCases.compactMap { accountType in
            guard let accounts = grouped[accountType], !accounts.isEmpty else { return nil }
            let totalBalance = accounts.reduce(0) { $0 + $1.balance }
            return AccountTypeGroup(
                accountType: accountType,
                accounts: accounts,
                totalBalance: totalBalance
            )
        }
    }
    
    // MARK: - Methods
    
    public func loadAccounts() async {
        isLoading = true
        
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // In real app, this would fetch from SwiftData
        accounts = createSampleAccounts()
        calculateFinancialSummary()
        
        isLoading = false
    }
    
    public func addAccount(_ account: Account) async {
        accounts.append(account)
        calculateFinancialSummary()
        
        // In real app, save to SwiftData
        // context.insert(account)
        // try? context.save()
    }
    
    public func updateAccount(_ account: Account) async {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            calculateFinancialSummary()
            
            // In real app, save to SwiftData
            // try? context.save()
        }
    }
    
    public func deleteAccount(_ account: Account) async {
        accounts.removeAll { $0.id == account.id }
        calculateFinancialSummary()
        
        // In real app, delete from SwiftData
        // context.delete(account)
        // try? context.save()
    }
    
    public func toggleAccountStatus(_ account: Account) async {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index].isActive.toggle()
            accounts[index].updatedAt = Date()
            
            // In real app, save to SwiftData
            await updateAccount(accounts[index])
        }
    }
    
    public func refreshBalances() async {
        isLoading = true
        
        // Simulate refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In real app, sync with bank APIs
        // Update balances based on latest transactions
        for account in accounts {
            account.updateBalance()
        }
        
        calculateFinancialSummary()
        isLoading = false
    }
    
    private func calculateFinancialSummary() {
        totalAssets = assetAccounts.reduce(0) { $0 + max($1.balance, 0) }
        totalLiabilities = liabilityAccounts.reduce(0) { $0 + abs(min($1.balance, 0)) }
        netWorth = totalAssets - totalLiabilities
    }
    
    // MARK: - Sample Data
    private func createSampleAccounts() -> [Account] {
        return [
            Account(
                name: "Primary Checking",
                accountType: .checking,
                balance: 2847.32,
                accountNumber: "****1234",
                institutionName: "Chase Bank",
                color: "#3882FF"
            ),
            Account(
                name: "High Yield Savings",
                accountType: .savings,
                balance: 15420.78,
                accountNumber: "****5678",
                institutionName: "Ally Bank",
                color: "#14CC66"
            ),
            Account(
                name: "Freedom Credit Card",
                accountType: .credit,
                balance: -1205.50,
                accountNumber: "****9012",
                institutionName: "Capital One",
                color: "#F03D4F"
            ),
            Account(
                name: "Investment Portfolio",
                accountType: .investment,
                balance: 48392.15,
                accountNumber: "****3456",
                institutionName: "Vanguard",
                color: "#F5A500"
            ),
            Account(
                name: "Emergency Fund",
                accountType: .savings,
                balance: 8500.00,
                accountNumber: "****7890",
                institutionName: "Marcus by Goldman Sachs",
                color: "#54E894"
            ),
            Account(
                name: "Business Checking",
                accountType: .business,
                balance: 5632.45,
                accountNumber: "****2468",
                institutionName: "Wells Fargo",
                color: "#1F56C2"
            ),
            Account(
                name: "Cash Wallet",
                accountType: .cash,
                balance: 127.50,
                color: "#99F7BF"
            )
        ]
    }
}

// MARK: - Supporting Types
public enum AccountSortOption: String, CaseIterable {
    case name = "Name"
    case balance = "Balance"
    case accountType = "Type"
    case dateCreated = "Date Created"
    case institution = "Institution"
    
    var iconName: String {
        switch self {
        case .name: return "textformat.abc"
        case .balance: return "dollarsign.circle"
        case .accountType: return "folder"
        case .dateCreated: return "calendar"
        case .institution: return "building.columns"
        }
    }
}

public struct AccountTypeGroup {
    let accountType: AccountType
    let accounts: [Account]
    let totalBalance: Double
    
    var displayBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "$\(totalBalance)"
    }
}

// MARK: - Main Accounts View
public struct AccountsView: View {
    @StateObject private var viewModel = AccountsViewModel()
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    
    @State private var showingAddAccount = false
    @State private var showingAccountDetail = false
    @State private var showingFilterSheet = false
    
    public var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: DesignTokens.Spacing.lg) {
                        
                        // Financial Summary Header
                        AccountsSummaryCard(viewModel: viewModel)
                            .slideInFromTop(delay: 0.0)
                        
                        // Search and Filter Section
                        SearchAndFilterSection(viewModel: viewModel, showingFilterSheet: $showingFilterSheet)
                            .slideInFromLeading(delay: 0.1)
                        
                        // Insights / Charts Section (only when there are accounts)
                        if viewModel.accounts.isEmpty == false {
                            AccountsChartsSection(dashboardViewModel: dashboardViewModel)
                                .slideInFromTrailing(delay: 0.15)
                        }
                        
                        // Accounts List
                        if viewModel.isLoading {
                            AccountsSkeletonLoader()
                        } else if viewModel.filteredAccounts.isEmpty {
                            EmptyAccountsView(showingAddAccount: $showingAddAccount)
                                .fadeInScale(delay: 0.3)
                        } else {
                            AccountsListSection(
                                viewModel: viewModel,
                                showingAccountDetail: $showingAccountDetail
                            )
                            .slideInFromBottom(delay: 0.2)
                        }
                        
                        // Bottom spacing
                        Spacer()
                            .frame(height: DesignTokens.Spacing.xl)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                }
            }
            .refreshable {
                await viewModel.loadAccounts()
                await dashboardViewModel.refreshDashboard()
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingFilterSheet = true
                    } label: {
                        Icon("line.horizontal.3.decrease.circle", context: .toolbar)
                    }
                    .accessibleButton(title: "Filter accounts", action: "opens filter options")
                    
                    Button {
                        showingAddAccount = true
                    } label: {
                        Icon("plus.circle.fill", context: .toolbar)
                    }
                    .accessibleButton(title: "Add account", action: "opens add account flow")
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingFilterSheet) {
            AccountsFilterView()
                .environmentObject(viewModel)
        }
        .sheet(item: $viewModel.selectedAccount) { account in
            AccountDetailView(account: account)
                .environmentObject(viewModel)
        }
        .task {
            await viewModel.loadAccounts()
            await dashboardViewModel.refreshDashboard()
        }
    }
}

// MARK: - Accounts Charts Section (Insights)
private struct AccountsChartsSection: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("Insights")
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
            
            // Simple Income vs Expenses summary
            FinancialCard(shadowLevel: .light) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Income")
                            .font(Typography.TextStyle.labelMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        Text(dashboardViewModel.monthlyIncome, format: .currency(code: "USD"))
                            .currencyText(amount: dashboardViewModel.monthlyIncome, style: .medium, color: DesignTokens.Colors.success)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xs) {
                        Text("Expenses")
                            .font(Typography.TextStyle.labelMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        Text(dashboardViewModel.monthlyExpenses, format: .currency(code: "USD"))
                            .currencyText(amount: dashboardViewModel.monthlyExpenses, style: .medium, color: DesignTokens.Colors.danger)
                    }
                }
            }
            .animation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8), value: dashboardViewModel.monthlyIncome + dashboardViewModel.monthlyExpenses)
            
            // Simple recent activity summary
            FinancialCard(shadowLevel: .light) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Recent Activity")
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    
                    HStack {
                        Text("Transactions this month")
                            .font(Typography.TextStyle.bodyMedium)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        Spacer()
                        Text("\(dashboardViewModel.recentTransactions.count)")
                            .font(Typography.TextStyle.bodyMedium)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    }
                }
            }
        }
    }
}

// MARK: - Accounts Summary Card
private struct AccountsSummaryCard: View {
    let viewModel: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .medium) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                
                // Net Worth Display
                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text("Total Net Worth")
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    
                    Text(viewModel.netWorth, format: .currency(code: "USD"))
                        .currencyText(amount: viewModel.netWorth, style: .display)
                        .accessibleAmount(viewModel.netWorth, context: "total net worth")
                }
                
                // Assets vs Liabilities
                HStack(spacing: DesignTokens.Spacing.xl) {
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Text("Assets")
                            .font(Typography.TextStyle.labelMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        
                        Text(viewModel.totalAssets, format: .currency(code: "USD"))
                            .currencyText(amount: viewModel.totalAssets, style: .medium, color: DesignTokens.Colors.success)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Text("Liabilities")
                            .font(Typography.TextStyle.labelMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        
                        Text(viewModel.totalLiabilities, format: .currency(code: "USD"))
                            .currencyText(amount: viewModel.totalLiabilities, style: .medium, color: DesignTokens.Colors.danger)
                    }
                }
                
                // Quick Stats
                HStack {
                    SummaryQuickStat(
                        title: "Accounts",
                        value: "\(viewModel.accounts.count)",
                        icon: "creditcard.2"
                    )
                    
                    Spacer()
                    
                    SummaryQuickStat(
                        title: "Active",
                        value: "\(viewModel.accounts.filter { $0.isActive }.count)",
                        icon: "checkmark.circle"
                    )
                    
                    Spacer()
                    
                    SummaryQuickStat(
                        title: "Types",
                        value: "\(Set(viewModel.accounts.map { $0.accountType }).count)",
                        icon: "folder.fill"
                    )
                }
            }
        }
    }
}

// MARK: - Quick Stat Component (renamed to avoid conflict)
private struct SummaryQuickStat: View {
    let title: String
    let value: String
    let icon: String
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Icon(icon, context: .status, color: themeManager.currentTheme.textColorTertiary)
                Text(title)
                    .font(Typography.TextStyle.labelSmall)
                    .foregroundColor(themeManager.currentTheme.textColorTertiary)
            }
            
            Text(value)
                .font(Typography.TextStyle.titleMedium)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
        }
    }
}

// MARK: - Search and Filter Section
private struct SearchAndFilterSection: View {
    @ObservedObject var viewModel: AccountsViewModel
    @Binding var showingFilterSheet: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            
            // Search Bar
            HStack(spacing: DesignTokens.Spacing.sm) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Icon("magnifyingglass", context: .inline, color: themeManager.currentTheme.textColorTertiary)
                    
                    TextField("Search accounts...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .accessibilityLabel("Search accounts")
                        .accessibilityHint("Enter account name, bank, or type to search")
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(themeManager.currentTheme.backgroundColorSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
                )
                
                // Filter Button
                Button {
                    showingFilterSheet = true
                } label: {
                    Icon("slider.horizontal.3", context: .inline)
                        .padding(DesignTokens.Spacing.sm)
                        .background(themeManager.currentTheme.primaryColor)
                        .foregroundColor(themeManager.currentTheme.textColorInverse)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            
            // Active Filters
            if viewModel.selectedAccountType != nil || viewModel.showInactiveAccounts {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        
                        if let accountType = viewModel.selectedAccountType {
                            FilterChip(
                                text: accountType.displayName,
                                icon: accountType.iconName
                            ) {
                                viewModel.selectedAccountType = nil
                            }
                        }
                        
                        if viewModel.showInactiveAccounts {
                            FilterChip(
                                text: "Including Inactive",
                                icon: "eye.slash"
                            ) {
                                viewModel.showInactiveAccounts = false
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xs)
                }
            }
        }
    }
}

// MARK: - Filter Chip
private struct FilterChip: View {
    let text: String
    let icon: String?
    let onRemove: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    init(text: String, icon: String? = nil, onRemove: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.onRemove = onRemove
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            if let icon = icon {
                Icon(icon, context: .status, color: themeManager.currentTheme.primaryColor)
            }
            
            Text(text)
                .font(Typography.TextStyle.labelMedium)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            Button {
                onRemove()
            } label: {
                Icon("xmark.circle.fill", context: .status, color: themeManager.currentTheme.textColorSecondary)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(themeManager.currentTheme.primaryColor.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Accounts List Section
private struct AccountsListSection: View {
    @ObservedObject var viewModel: AccountsViewModel
    @Binding var showingAccountDetail: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            
            // Section Header
            HStack {
                Text("Your Accounts")
                    .font(Typography.TextStyle.headlineSmall)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Spacer()
                
                // Sort Menu
                Menu {
                    ForEach(AccountSortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if viewModel.sortOption == option {
                                    Icon("checkmark", context: .status)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Icon("arrow.up.arrow.down", context: .status, color: themeManager.currentTheme.textColorSecondary)
                        Text("Sort")
                            .font(Typography.TextStyle.labelMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    }
                }
            }
            
            // Account Type Groups or Flat List
            if viewModel.searchText.isEmpty && viewModel.selectedAccountType == nil {
                // Grouped by account type
                VStack(spacing: DesignTokens.Spacing.lg) {
                    ForEach(viewModel.accountTypeGroups, id: \.accountType) { group in
                        AccountTypeGroupView(group: group, viewModel: viewModel)
                    }
                }
            } else {
                // Flat list for search results
                VStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(Array(viewModel.filteredAccounts.enumerated()), id: \.1.id) { index, account in
                        AccountCardView(account: account) {
                            viewModel.selectedAccount = account
                        }
                        .slideInFromTrailing(delay: Double(index) * 0.05)
                    }
                }
            }
        }
    }
}

// MARK: - Account Type Group View
private struct AccountTypeGroupView: View {
    let group: AccountTypeGroup
    @ObservedObject var viewModel: AccountsViewModel
    @State private var isExpanded = true
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .light) {
            VStack(spacing: DesignTokens.Spacing.md) {
                
                // Group Header
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        // Account Type Icon and Name
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Icon(
                                group.accountType.iconName,
                                context: .inline,
                                color: Color(hex: group.accountType.defaultColor)
                            )
                            
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Text(group.accountType.displayName)
                                    .font(Typography.TextStyle.titleMedium)
                                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                                
                                Text("\(group.accounts.count) account\(group.accounts.count == 1 ? "" : "s")")
                                    .font(Typography.TextStyle.labelSmall)
                                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Total Balance
                        VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xs) {
                            Text(group.displayBalance)
                                .currencyText(amount: group.totalBalance, style: .medium)
                            
                            Icon(
                                isExpanded ? "chevron.up" : "chevron.down",
                                context: .status,
                                color: themeManager.currentTheme.textColorSecondary
                            )
                        }
                    }
                }
                
                // Accounts List (Collapsible)
                if isExpanded {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(group.accounts, id: \.id) { account in
                            AccountRowView(account: account) {
                                viewModel.selectedAccount = account
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                }
            }
        }
    }
}

// MARK: - Account Card View (Featured Display)
private struct AccountCardView: View {
    let account: Account
    let onTap: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            FinancialCard(shadowLevel: .medium) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    
                    // Account Icon
                    Circle()
                        .fill(Color(hex: account.color).opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Icon(
                                account.accountType.iconName,
                                context: .inline,
                                color: Color(hex: account.color)
                            )
                        )
                    
                    // Account Details
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(account.name)
                            .font(Typography.TextStyle.titleMedium)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        if let institution = account.institutionName {
                            Text(institution)
                                .font(Typography.TextStyle.labelMedium)
                                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                                .lineLimit(1)
                        }
                        
                        Text(account.maskedAccountNumber)
                            .font(Typography.TextStyle.labelSmall)
                            .foregroundColor(themeManager.currentTheme.textColorTertiary)
                    }
                    
                    Spacer()
                    
                    // Balance and Status
                    VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xs) {
                        Text(account.balance, format: .currency(code: account.currency))
                            .currencyText(amount: account.balance, style: .large)
                        
                        HStack(spacing: DesignTokens.Spacing.xs) {
                            if !account.isActive {
                                Text("INACTIVE")
                                    .font(Typography.TextStyle.labelSmall)
                                    .foregroundColor(DesignTokens.Colors.warning)
                                    .padding(.horizontal, DesignTokens.Spacing.xs)
                                    .padding(.vertical, DesignTokens.Spacing.xxxs)
                                    .background(DesignTokens.Colors.warning.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            Icon("chevron.right", context: .status, color: themeManager.currentTheme.textColorTertiary)
                        }
                    }
                }
            }
        }
        .cardHover()
        .accessibleAccountCard(
            accountName: account.name,
            balance: account.balance,
            accountType: account.accountType.displayName,
            onTap: onTap
        )
    }
}

// MARK: - Account Row View (Compact Display)
private struct AccountRowView: View {
    let account: Account
    let onTap: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.md) {
                
                // Account Icon
                Circle()
                    .fill(Color(hex: account.color).opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Icon(
                            account.accountType.iconName,
                            context: .status,
                            color: Color(hex: account.color)
                        )
                    )
                
                // Account Details
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(account.name)
                        .font(Typography.TextStyle.bodyMedium)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        if let institution = account.institutionName {
                            Text(institution)
                                .font(Typography.TextStyle.labelSmall)
                                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        }
                        
                        Text(account.maskedAccountNumber)
                            .font(Typography.TextStyle.labelSmall)
                            .foregroundColor(themeManager.currentTheme.textColorTertiary)
                    }
                }
                
                Spacer()
                
                // Balance
                VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xs) {
                    Text(account.balance, format: .currency(code: account.currency))
                        .currencyText(amount: account.balance, style: .medium)
                    
                    if !account.isActive {
                        Text("Inactive")
                            .font(Typography.TextStyle.labelSmall)
                            .foregroundColor(DesignTokens.Colors.warning)
                    }
                }
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(account.name), \(account.displayBalance)")
        .accessibilityHint("Double tap to view account details")
    }
}

// MARK: - Empty Accounts View
private struct EmptyAccountsView: View {
    @Binding var showingAddAccount: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .medium) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                
                // Empty State Icon
                VectorIcons.WalletShape()
                    .fill(themeManager.currentTheme.textColorTertiary.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                // Empty State Text
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("No Accounts Yet")
                        .font(Typography.TextStyle.headlineSmall)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    
                    Text("Add your first account to start tracking your finances")
                        .font(Typography.TextStyle.bodyMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Add Account Button
                BrandedButton("Add Your First Account", style: .primary) {
                    showingAddAccount = true
                }
                .frame(maxWidth: 200)
            }
            .padding(.vertical, DesignTokens.Spacing.lg)
        }
    }
}

// MARK: - Accounts Skeleton Loader
private struct AccountsSkeletonLoader: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ForEach(0..<5, id: \.self) { _ in
                FinancialCard(shadowLevel: .light) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        // Avatar skeleton
                        Circle()
                            .fill(themeManager.currentTheme.backgroundColorTertiary)
                            .frame(width: 60, height: 60)
                        
                        // Content skeleton
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(themeManager.currentTheme.backgroundColorTertiary)
                                .frame(width: 120, height: 16)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(themeManager.currentTheme.backgroundColorTertiary)
                                .frame(width: 80, height: 12)
                        }
                        
                        Spacer()
                        
                        // Balance skeleton
                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.currentTheme.backgroundColorTertiary)
                            .frame(width: 80, height: 20)
                    }
                }
                .shimmerLegacy()
            }
        }
    }
}

// MARK: - Shimmer Effect Extension (renamed locally to avoid ambiguity)
extension View {
    func shimmerLegacy() -> some View {
        modifier(ShimmerLegacyModifier())
    }
}

private struct ShimmerLegacyModifier: ViewModifier {
    @State private var phase = 0.0
    
    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: phase
                )
            }
            .onAppear {
                phase = 300
            }
    }
}

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

#if DEBUG
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AccountsView()
                .environmentObject(ThemeManager())
                .environmentObject(AccessibilitySystem.AccessibilityManager())
                .previewDisplayName("Accounts View")
            
            // Empty state
            AccountsView()
                .environmentObject(ThemeManager())
                .environmentObject(AccessibilitySystem.AccessibilityManager())
                .previewDisplayName("Empty Accounts")
        }
    }
}
#endif

//
//  AccountDetailAndFilterView.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Detail + Filter (responsive container)
public struct AccountDetailAndFilterView: View {
    // Input
    let account: Account

    // Data / State
    @StateObject private var detailVM = AccountDetailViewModel()
    @EnvironmentObject private var accountsVM: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingFiltersSheet = false

    // Layout
    private let centerColumnMaxWidth: CGFloat = 820

    public init(account: Account) {
        self.account = account
    }

    public var body: some View {
        Group {
            if isTwoColumn {
                twoColumnLayout
            } else {
                // Compact width: reuse the existing AccountDetailView and present filters as a sheet
                AccountDetailView(account: account)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingFiltersSheet = true
                            } label: {
                                Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            }
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .accessibilityLabel("Open Filters")
                        }
                    }
                    .sheet(isPresented: $showingFiltersSheet) {
                        AccountsFilterView()
                            .environmentObject(accountsVM)
                            .environmentObject(themeManager)
                            .environmentObject(accessibilityManager)
                    }
            }
        }
        .task { await detailVM.loadAccountData(for: account) }
    }

    // MARK: - Layout helpers
    private var isTwoColumn: Bool {
        #if os(macOS) || os(tvOS) || os(visionOS)
        return true
        #else
        return sizeClass == .regular
        #endif
    }

    // MARK: - Regular / Desktop width: Side-by-side (Details + Filters)
    private var twoColumnLayout: some View {
        // No inner NavigationView and no full-screen background here.
        // Let the parent shell provide the Dock and the global background.
        ScrollView {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                // DETAILS COLUMN
                VStack(spacing: DesignTokens.Spacing.lg) {
                    AccountDetailHeaderCard(account: account, showingEditSheet: $showingEditSheet)

                    AccountQuickActionsSection(account: account, viewModel: detailVM)

                    AccountStatisticsSection(account: account)

                    AccountTransactionsSection(account: account, transactions: detailVM.recentTransactions)

                    AccountSettingsSection(account: account, showingDeleteAlert: $showingDeleteAlert)

                    Spacer().frame(height: DesignTokens.Spacing.xl)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // FILTERS COLUMN
                InlineFiltersPanel()
                    .frame(maxWidth: 380)
            }
            .frame(maxWidth: centerColumnMaxWidth + 380 + DesignTokens.Spacing.lg) // center content bounds
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Account")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button("Done") { dismiss() }
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
        }
        // Edit sheet and delete alert (same behavior as AccountDetailView)
        .sheet(isPresented: $showingEditSheet) {
            AccountEditView(account: account)
                .environmentObject(accountsVM)
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task { await deleteAccount() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete '\(account.name)'? This action cannot be undone.")
        }
        .refreshable {
            await detailVM.refreshAccountData(for: account)
        }
    }

    // MARK: - Actions
    private func deleteAccount() async {
        await accountsVM.deleteAccount(account)
        accessibilityManager.provideTactileFeedback(for: .itemSelected)
        dismiss()
    }
}

// MARK: - Inline Filters Panel (side column)
private struct InlineFiltersPanel: View {
    @EnvironmentObject private var viewModel: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Filters")
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)

            // Account Type
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Account Type")
                    .font(Typography.TextStyle.labelMedium)
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)

                FinancialCard(shadowLevel: .light) {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        // All Types
                        FilterOptionRow(
                            title: "All Types",
                            icon: "folder.fill",
                            isSelected: viewModel.selectedAccountType == nil
                        ) {
                            accessibilityManager.provideTactileFeedback(for: .itemSelected)
                            viewModel.selectedAccountType = nil
                        }

                        ForEach(AccountType.allCases, id: \.self) { type in
                            FilterOptionRow(
                                title: type.displayName,
                                icon: type.iconName,
                                isSelected: viewModel.selectedAccountType == type
                            ) {
                                accessibilityManager.provideTactileFeedback(for: .itemSelected)
                                viewModel.selectedAccountType = type
                            }
                        }
                    }
                }
            }

            // Sort
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Sort By")
                    .font(Typography.TextStyle.labelMedium)
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)

                FinancialCard(shadowLevel: .light) {
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        ForEach(AccountSortOption.allCases, id: \.self) { option in
                            Button {
                                accessibilityManager.provideTactileFeedback(for: .itemSelected)
                                viewModel.sortOption = option
                            } label: {
                                HStack {
                                    Icon(option.iconName, context: .status, color: themeManager.currentTheme.textColorSecondary)
                                    Text(option.rawValue)
                                        .font(Typography.TextStyle.bodyMedium)
                                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                                    Spacer()
                                    if viewModel.sortOption == option {
                                        Icon("checkmark.circle.fill", context: .status, color: themeManager.currentTheme.primaryColor)
                                    }
                                }
                                .padding(.vertical, DesignTokens.Spacing.xs)
                            }
                            .buttonPress()

                            if option != AccountSortOption.allCases.last {
                                Divider().background(themeManager.currentTheme.dividerColor)
                            }
                        }
                    }
                }
            }

            // Display options
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Display")
                    .font(Typography.TextStyle.labelMedium)
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)

                FinancialCard(shadowLevel: .light) {
                    HStack {
                        Icon("eye.slash", context: .status, color: themeManager.currentTheme.textColorSecondary)
                        Text("Show Inactive Accounts")
                            .font(Typography.TextStyle.bodyMedium)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        Spacer()
                        Toggle("", isOn: $viewModel.showInactiveAccounts)
                            .labelsHidden()
                            .tint(themeManager.currentTheme.primaryColor)
                    }
                }
            }

            // Reset / Apply
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Reset") {
                    accessibilityManager.provideTactileFeedback(for: .itemSelected)
                    viewModel.selectedAccountType = nil
                    viewModel.showInactiveAccounts = false
                    viewModel.sortOption = .balance
                }
                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
                .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)

                BrandedButton("Apply", style: .primary) {
                    accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                    // No-op in inline panel; values already live-update the AccountsViewModel.
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(themeManager.currentTheme.backgroundColor.opacity(0.001)) // hit testing area
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Previews
#if DEBUG
struct AccountDetailAndFilterView_Previews: PreviewProvider {
    static var previews: some View {
        let accountsVM = AccountsViewModel()
        let theme = ThemeManager()
        let accessibility = AccessibilitySystem.AccessibilityManager()

        let sample = Account(
            name: "Primary Checking",
            accountType: .checking,
            balance: 2847.32,
            accountNumber: "****1234",
            institutionName: "Chase Bank",
            color: "#3882FF"
        )

        // Wide (two-column)
        AccountDetailAndFilterView(account: sample)
            .environmentObject(accountsVM)
            .environmentObject(theme)
            .environmentObject(accessibility)
            .previewLayout(.fixed(width: 1200, height: 900))
            .previewDisplayName("Detail + Filters (Regular Width)")

        // Compact (sheet for filters)
        AccountDetailAndFilterView(account: sample)
            .environmentObject(accountsVM)
            .environmentObject(theme)
            .environmentObject(accessibility)
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("Detail (Compact) + Filter Sheet")
    }
}
#endif

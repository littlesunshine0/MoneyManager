//
//  AccountsFilterView 2.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Accounts Filter Panel (Alternative UI)
public struct AccountsFilterPanelView: View {
    @EnvironmentObject private var viewModel: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        
                        // Account Type Filter
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            Text("Account Type")
                                .font(Typography.TextStyle.headlineSmall)
                                .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            
                            VStack(spacing: DesignTokens.Spacing.sm) {
                                // All Types Option
                                FilterOptionRow(
                                    title: "All Types",
                                    icon: "folder.fill",
                                    isSelected: viewModel.selectedAccountType == nil
                                ) {
                                    viewModel.selectedAccountType = nil
                                }
                                
                                ForEach(AccountType.allCases, id: \.self) { accountType in
                                    FilterOptionRow(
                                        title: accountType.displayName,
                                        icon: accountType.iconName,
                                        isSelected: viewModel.selectedAccountType == accountType
                                    ) {
                                        viewModel.selectedAccountType = accountType
                                    }
                                }
                            }
                        }
                        .slideInFromTop()
                        
                        // Sort Options
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            Text("Sort By")
                                .font(Typography.TextStyle.headlineSmall)
                                .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            
                            VStack(spacing: DesignTokens.Spacing.sm) {
                                ForEach(AccountSortOption.allCases, id: \.self) { sortOption in
                                    FilterOptionRow(
                                        title: sortOption.rawValue,
                                        icon: sortOption.iconName,
                                        isSelected: viewModel.sortOption == sortOption
                                    ) {
                                        viewModel.sortOption = sortOption
                                    }
                                }
                            }
                        }
                        .slideInFromLeading(delay: 0.2)
                        
                        // Display Options
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            Text("Display Options")
                                .font(Typography.TextStyle.headlineSmall)
                                .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            
                            FinancialCard(shadowLevel: .light) {
                                VStack(spacing: DesignTokens.Spacing.md) {
                                    
                                    // Show Inactive Accounts
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
                        }
                        .slideInFromTrailing(delay: 0.4)
                        
                        // Reset Button
                        BrandedButton("Reset All Filters", style: .secondary) {
                            resetFilters()
                        }
                        .slideInFromBottom(delay: 0.6)
                        
                        Spacer()
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                }
            }
            .navigationTitle("Filter & Sort")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
    }
    
    private func resetFilters() {
        viewModel.selectedAccountType = nil
        viewModel.sortOption = .balance
        viewModel.showInactiveAccounts = false
    }
}

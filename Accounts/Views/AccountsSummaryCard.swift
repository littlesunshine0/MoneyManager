//
//  AccountsSummaryCard.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//


import SwiftUI

/// A card that displays the total net worth, assets, and liabilities.
private struct AccountsSummaryCard: View {
    // The view model containing the financial data.
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
                    QuickStat(
                        title: "Accounts",
                        value: "\(viewModel.accounts.count)",
                        icon: "creditcard.fill"
                    )
                    
                    Spacer()
                    
                    QuickStat(
                        title: "Active",
                        value: "\(viewModel.accounts.filter { $0.isActive }.count)",
                        icon: "checkmark.circle"
                    )
                    
                    Spacer()
                    
                    QuickStat(
                        title: "Types",
                        value: "\(Set(viewModel.accounts.map { $0.accountType }).count)",
                        icon: "folder.fill"
                    )
                }
            }
        }
    }
}
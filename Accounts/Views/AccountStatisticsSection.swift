//
//  AccountStatisticsSection.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Statistics Section
struct AccountStatisticsSection: View {
    let account: Account
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("This Month")
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
            
            FinancialCard(shadowLevel: .light) {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    
                    // Income vs Expenses
                    HStack {
                        StatisticItem(
                            title: "Income",
                            value: 3200.00,
                            icon: "arrow.down.circle.fill",
                            color: DesignTokens.Colors.success
                        )
                        
                        Spacer()
                        
                        StatisticItem(
                            title: "Expenses",
                            value: 1863.24,
                            icon: "arrow.up.circle.fill",
                            color: DesignTokens.Colors.danger
                        )
                    }
                    
                    Divider()
                        .background(themeManager.currentTheme.dividerColor)
                    
                    // Net Income
                    HStack {
                        Text("Net Income")
                            .font(Typography.TextStyle.bodyMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        
                        Spacer()
                        
                        Text(1336.76, format: .currency(code: account.currency))
                            .currencyText(amount: 1336.76, style: .medium, color: DesignTokens.Colors.success)
                    }
                    
                    // Transaction Count
                    HStack {
                        Text("Transactions")
                            .font(Typography.TextStyle.bodyMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        
                        Spacer()
                        
                        Text("23")
                            .font(Typography.TextStyle.bodyMedium)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    }
                }
            }
        }
    }
}

// MARK: - Statistic Item
private struct StatisticItem: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Icon(icon, context: .status, color: color)
                Text(title)
                    .font(Typography.TextStyle.labelMedium)
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
            }
            
            Text(value, format: .currency(code: "USD"))
                .currencyText(amount: value, style: .medium, color: color)
        }
    }
}

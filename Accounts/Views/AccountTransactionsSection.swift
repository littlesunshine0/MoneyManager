//
//  AccountTransactionsSection.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Transactions Section
struct AccountTransactionsSection: SwiftUI.View {
    let account: Account
    let transactions: [Transaction]
    @SwiftUI.EnvironmentObject private var themeManager: ThemeManager
    
    var body: some SwiftUI.View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Recent Transactions")
                    .font(Typography.TextStyle.headlineSmall)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all transactions
                }
                .font(Typography.TextStyle.bodyMedium)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            FinancialCard(shadowLevel: .light) {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        AccountTransactionRow(transaction: transaction)
                        
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

// MARK: - Account Transaction Row
private struct AccountTransactionRow: SwiftUI.View {
    let transaction: Transaction
    @SwiftUI.EnvironmentObject private var themeManager: ThemeManager
    
    var body: some SwiftUI.View {
        HStack(spacing: DesignTokens.Spacing.md) {
            
            // Transaction Icon
            Circle()
                .fill(Color(hex: transaction.type.color).opacity(0.1))
                .frame(width: 35, height: 35)
                .overlay(
                    Icon(
                        transaction.type.iconName,
                        context: .status,
                        color: Color(hex: transaction.type.color)
                    )
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(transaction.description)
                    .font(Typography.TextStyle.bodyMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .lineLimit(1)
                
                Text(transaction.date, format: .dateTime.month().day().hour().minute())
                    .font(Typography.TextStyle.labelSmall)
                    .foregroundColor(themeManager.currentTheme.textColorTertiary)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.displayAmount)
                .currencyText(
                    amount: transaction.amountWithSign,
                    style: .medium,
                    color: transaction.type.isExpense ? DesignTokens.Colors.danger : DesignTokens.Colors.success
                )
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(transaction.accessibilityDescription)
    }
}

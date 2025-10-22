//
//  AccountDetailHeaderCard.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Detail Header Card
struct AccountDetailHeaderCard: View {
    let account: Account
    @Binding var showingEditSheet: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .heavy) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                
                // Account Icon and Basic Info
                HStack {
                    Circle()
                        .fill(Color(hex: account.color).opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Icon(
                                account.accountType.iconName,
                                context: .app,
                                color: Color(hex: account.color)
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(account.name)
                            .font(Typography.TextStyle.headlineSmall)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            .lineLimit(2)
                        
                        Text(account.accountType.displayName)
                            .font(Typography.TextStyle.labelMedium)
                            .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        
                        if let institution = account.institutionName {
                            Text(institution)
                                .font(Typography.TextStyle.labelMedium)
                                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        }
                        
                        Text(account.maskedAccountNumber)
                            .font(Typography.TextStyle.labelSmall)
                            .foregroundColor(themeManager.currentTheme.textColorTertiary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(themeManager.currentTheme.dividerColor)
                
                // Balance Display
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text("Current Balance")
                        .font(Typography.TextStyle.labelMedium)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    
                    Text(account.balance, format: .currency(code: account.currency))
                        .currencyText(amount: account.balance, style: .display)
                        .accessibleAmount(account.balance, context: "current balance")
                }
                
                // Account Status
                HStack {
                    AccountStatusBadge(account: account)
                    
                    Spacer()
                    
                    Button("Edit Account") {
                        showingEditSheet = true
                    }
                    .font(Typography.TextStyle.labelMedium)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .accessibleButton(title: "Edit Account", action: "opens account settings")
                }
            }
        }
    }
}

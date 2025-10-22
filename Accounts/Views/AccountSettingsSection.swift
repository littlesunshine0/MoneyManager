//
//  AccountSettingsSection.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Settings Section
struct AccountSettingsSection: View {
    let account: Account
    @Binding var showingDeleteAlert: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Settings")
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
            
            FinancialCard(shadowLevel: .light) {
                VStack(spacing: DesignTokens.Spacing.md) {
                    
                    // Toggle Active Status
                    HStack {
                        Icon("power", context: .status, color: themeManager.currentTheme.textColorSecondary)
                        
                        Text("Active Account")
                            .font(Typography.TextStyle.bodyMedium)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        
                        Spacer()
                        
                        Toggle("", isOn: .constant(account.isActive))
                            .labelsHidden()
                            .tint(themeManager.currentTheme.primaryColor)
                            .onChange(of: account.isActive) { _ in
                                Task {
                                    await accountsViewModel.toggleAccountStatus(account)
                                }
                            }
                    }
                    
                    Divider()
                        .background(themeManager.currentTheme.dividerColor)
                    
                    // Export Data
                    Button {
                        // Export account data
                    } label: {
                        HStack {
                            Icon("square.and.arrow.up", context: .status, color: themeManager.currentTheme.primaryColor)
                            
                            Text("Export Data")
                                .font(Typography.TextStyle.bodyMedium)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            Spacer()
                            
                            Icon("chevron.right", context: .status, color: themeManager.currentTheme.textColorTertiary)
                        }
                    }
                    .accessibleButton(title: "Export Data", action: "exports account data")
                    
                    Divider()
                        .background(themeManager.currentTheme.dividerColor)
                    
                    // Delete Account
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Icon("trash", context: .status, color: DesignTokens.Colors.danger)
                            
                            Text("Delete Account")
                                .font(Typography.TextStyle.bodyMedium)
                                .foregroundColor(DesignTokens.Colors.danger)
                            
                            Spacer()
                        }
                    }
                    .accessibleButton(title: "Delete Account", action: "deletes this account")
                }
            }
        }
    }
}

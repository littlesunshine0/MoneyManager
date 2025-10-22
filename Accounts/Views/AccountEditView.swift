//
//  AccountEditView.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Edit View
public struct AccountEditView: View {
    let account: Account
    @StateObject private var viewModel = AccountEditViewModel()
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: EditAccountField?
    
    public init(account: Account) {
        self.account = account
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        
                        // Account Icon Selection
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            Text("Account Color")
                                .font(Typography.TextStyle.titleSmall)
                                .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            
                            AccountColorPicker(selectedColor: $viewModel.selectedColor)
                        }
                        .slideInFromTop()
                        
                        // Edit Form
                        VStack(spacing: DesignTokens.Spacing.lg) {
                            
                            // Account Name
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Text("Account Name")
                                    .font(Typography.TextStyle.titleSmall)
                                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                                
                                TextField("Account name", text: $viewModel.accountName)
                                    .textFieldStyle(EditAccountTextFieldStyle())
                                    .focused($focusedField, equals: .accountName)
                            }
                            .slideInFromLeading(delay: 0.2)
                            
                            // Institution Name
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Text("Institution")
                                    .font(Typography.TextStyle.titleSmall)
                                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                                
                                TextField("Bank or institution", text: $viewModel.institutionName)
                                    .textFieldStyle(EditAccountTextFieldStyle())
                                    .focused($focusedField, equals: .institutionName)
                            }
                            .slideInFromTrailing(delay: 0.3)
                            
                            // Account Number
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Text("Account Number")
                                    .font(Typography.TextStyle.titleSmall)
                                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                                
                                TextField("Account number", text: $viewModel.accountNumber)
                                    .textFieldStyle(EditAccountTextFieldStyle())
                                    .focused($focusedField, equals: .accountNumber)
                            }
                            .slideInFromLeading(delay: 0.4)
                            
                            // Current Balance
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Text("Current Balance")
                                    .font(Typography.TextStyle.titleSmall)
                                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                                
                                HStack {
                                    Text("$")
                                        .font(Typography.TextStyle.bodyLarge)
                                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                                    
                                    TextField("0.00", value: $viewModel.balance, format: .number.precision(.fractionLength(2)))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                        .focused($focusedField, equals: .balance)
                                }
                                .padding()
                                .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
                                .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)
                            }
                            .slideInFromTrailing(delay: 0.5)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                }
            }
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle("Edit Account")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveChanges()
                        }
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .disabled(!viewModel.hasChanges)
                }
            }
        }
        .onAppear {
            viewModel.loadAccount(account)
        }
    }
    
    private func saveChanges() async {
        // Update account with new values
        let updatedAccount = account
        updatedAccount.name = viewModel.accountName
        updatedAccount.institutionName = viewModel.institutionName.isEmpty ? nil : viewModel.institutionName
        updatedAccount.accountNumber = viewModel.accountNumber.isEmpty ? nil : viewModel.accountNumber
        updatedAccount.balance = viewModel.balance
        updatedAccount.color = viewModel.selectedColor
        updatedAccount.updatedAt = Date()
        
        await accountsViewModel.updateAccount(updatedAccount)
        dismiss()
    }
}

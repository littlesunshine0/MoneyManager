//
//  AccountDetailView.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

public struct AccountDetailView: View {
    let account: Account
    
    @StateObject private var viewModel = AccountDetailViewModel()
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private let centerColumnMaxWidth: CGFloat = 820
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public init(account: Account) {
        self.account = account
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    // Centered column replacement for CenteredColumn
                    HStack {
                        Spacer(minLength: DesignTokens.Spacing.md)
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                            let isTwoColumn: Bool = {
                                #if os(macOS) || os(tvOS) || os(visionOS)
                                return true
                                #else
                                return horizontalSizeClass == .regular
                                #endif
                            }()
                            
                            if isTwoColumn {
                                twoColumnLayout
                            } else {
                                singleColumnLayout
                            }
                        }
                        .frame(maxWidth: centerColumnMaxWidth)
                        Spacer(minLength: DesignTokens.Spacing.md)
                    }
                }
            }
            .navigationTitle("Account Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                }
            }
        }
        .refreshable {
            await viewModel.refreshAccountData(for: account)
        }
        .sheet(isPresented: $showingEditSheet) {
            AccountEditView(account: account)
                .environmentObject(accountsViewModel)
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task { await deleteAccount() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete '\(account.name)'? This action cannot be undone.")
        }
        .task {
            await viewModel.loadAccountData(for: account)
        }
    }
    
    private var singleColumnLayout: some View {
        LazyVStack(spacing: DesignTokens.Spacing.lg) {
            AccountDetailHeaderCard(account: account, showingEditSheet: $showingEditSheet)
                .slideInFromTop()
            
            AccountQuickActionsSection(account: account, viewModel: viewModel)
                .slideInFromLeading(delay: 0.1)
            
            AccountStatisticsSection(account: account)
                .slideInFromTrailing(delay: 0.2)
            
            AccountTransactionsSection(account: account, transactions: viewModel.recentTransactions)
                .slideInFromBottom(delay: 0.3)
            
            AccountSettingsSection(account: account, showingDeleteAlert: $showingDeleteAlert)
                .slideInFromBottom(delay: 0.4)
            
            Spacer().frame(height: DesignTokens.Spacing.xl)
        }
    }
    
    private var twoColumnLayout: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                AccountDetailHeaderCard(account: account, showingEditSheet: $showingEditSheet)
                    .slideInFromTop()
                
                AccountQuickActionsSection(account: account, viewModel: viewModel)
                    .slideInFromLeading(delay: 0.1)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            VStack(spacing: DesignTokens.Spacing.lg) {
                AccountStatisticsSection(account: account)
                    .slideInFromTrailing(delay: 0.2)
                
                AccountTransactionsSection(account: account, transactions: viewModel.recentTransactions)
                    .slideInFromBottom(delay: 0.3)
                
                AccountSettingsSection(account: account, showingDeleteAlert: $showingDeleteAlert)
                    .slideInFromBottom(delay: 0.4)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
    
    private func deleteAccount() async {
        await accountsViewModel.deleteAccount(account)
        accessibilityManager.provideTactileFeedback(for: .itemSelected)
        dismiss()
    }
}

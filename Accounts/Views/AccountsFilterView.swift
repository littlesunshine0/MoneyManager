//
//  AccountsFilterView.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

/// A view that allows users to filter and sort the accounts list.
public struct AccountsFilterView: View {
    @EnvironmentObject private var viewModel: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                        
                        // Account Type
                        sectionHeader("Account Type", icon: "folder")
                        typeGrid
                        
                        // Status
                        sectionHeader("Status", icon: "eye")
                        statusToggle
                        
                        // Sort By
                        sectionHeader("Sort By", icon: "arrow.up.arrow.down")
                        sortOptions
                        
                        Spacer(minLength: DesignTokens.Spacing.xl)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.lg)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomActions
                .background(themeManager.currentTheme.backgroundColor)
        }
    }
    
    // MARK: - Sections
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Icon(icon, context: .status, color: themeManager.currentTheme.textColorSecondary)
            Text(title)
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
        }
    }
    
    private var typeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.md) {
            ForEach(AccountType.allCases, id: \.self) { type in
                let isSelected = viewModel.selectedAccountType == type
                Button {
                    accessibilityManager.provideTactileFeedback(for: .itemSelected)
                    viewModel.selectedAccountType = isSelected ? nil : type
                } label: {
                    FinancialCard(shadowLevel: isSelected ? .medium : .light) {
                        HStack(spacing: DesignTokens.Spacing.md) {
                            Circle()
                                .fill(Color(hex: type.defaultColor).opacity(0.12))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Icon(type.iconName, context: .status, color: Color(hex: type.defaultColor))
                                )
                            Text(type.displayName)
                                .font(Typography.TextStyle.bodyMedium)
                                .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            Spacer()
                            if isSelected {
                                Icon("checkmark.circle.fill", context: .status, color: themeManager.currentTheme.primaryColor)
                            }
                        }
                    }
                }
                .buttonPress()
            }
        }
    }
    
    private var statusToggle: some View {
        FinancialCard(shadowLevel: .light) {
            HStack {
                Icon("eye.slash", context: .status, color: themeManager.currentTheme.textColorSecondary)
                Text("Include Inactive Accounts")
                    .font(Typography.TextStyle.bodyMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                Spacer()
                Toggle("", isOn: $viewModel.showInactiveAccounts)
                    .labelsHidden()
                    .tint(themeManager.currentTheme.primaryColor)
            }
        }
    }
    
    private var sortOptions: some View {
        FinancialCard(shadowLevel: .light) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
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
    
    private var bottomActions: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Button("Clear All") {
                accessibilityManager.provideTactileFeedback(for: .itemSelected)
                viewModel.selectedAccountType = nil
                viewModel.showInactiveAccounts = false
                viewModel.sortOption = .balance
            }
            .foregroundColor(themeManager.currentTheme.textColorSecondary)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
            .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)
            
            BrandedButton("Apply", style: .primary) {
                accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                dismiss()
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }
}

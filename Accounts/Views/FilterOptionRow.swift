//
//  FilterOptionRow.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Filter Option Row
struct FilterOptionRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    
    var body: some View {
        Button(action: {
            accessibilityManager.provideTactileFeedback(for: .itemSelected)
            onTap()
        }) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Icon(icon, context: .inline, color: themeManager.currentTheme.textColorSecondary)
                
                Text(title)
                    .font(Typography.TextStyle.bodyMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Spacer()
                
                if isSelected {
                    Icon("checkmark.circle.fill", context: .status, color: themeManager.currentTheme.primaryColor)
                } else {
                    Circle()
                        .stroke(themeManager.currentTheme.borderColor, lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.vertical, DesignTokens.Spacing.sm)
        }
        .buttonPress()
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

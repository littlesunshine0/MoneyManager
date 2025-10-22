//
//  QuickStat.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//


import SwiftUI

/// A view that displays a single, important statistic with a title and an icon.
/// It's designed to be used in summary cards or dashboards.
struct QuickStat: View {
    let title: String
    let value: String
    let icon: String
    
    // The themeManager provides access to the current app theme for styling.
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            // The icon and title are grouped in an HStack.
            HStack(spacing: DesignTokens.Spacing.xs) {
                Icon(icon, context: .status, color: themeManager.currentTheme.textColorTertiary)
                Text(title)
                    .font(Typography.TextStyle.labelSmall)
                    .foregroundColor(themeManager.currentTheme.textColorTertiary)
            }
            
            // The main value is displayed in a larger font.
            Text(value)
                .font(Typography.TextStyle.titleMedium)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
        }
    }
}

// MARK: - Previews

struct QuickStat_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 40) {
            QuickStat(
                title: "Accounts",
                value: "7",
                icon: "creditcard.fill"
            )
            
            QuickStat(
                title: "Active",
                value: "5",
                icon: "checkmark.circle"
            )
            
            QuickStat(
                title: "Types",
                value: "4",
                icon: "folder.fill"
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .environmentObject(ThemeManager()) // Injects a theme manager for the preview.
    }
}
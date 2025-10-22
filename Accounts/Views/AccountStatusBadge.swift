//
//  AccountStatusBadge.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Status Badge
struct AccountStatusBadge: View {
    let account: Account
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Circle()
                .fill(account.isActive ? DesignTokens.Colors.success : DesignTokens.Colors.warning)
                .frame(width: 8, height: 8)
            
            Text(account.isActive ? "Active" : "Inactive")
                .font(Typography.TextStyle.labelSmall)
                .foregroundColor(account.isActive ? DesignTokens.Colors.success : DesignTokens.Colors.warning)
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background((account.isActive ? DesignTokens.Colors.success : DesignTokens.Colors.warning).opacity(0.1))
        .clipShape(Capsule())
    }
}

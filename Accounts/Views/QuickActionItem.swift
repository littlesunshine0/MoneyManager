//
//  QuickActionItem.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI
import Foundation

// MARK: - New Quick Actions (4-per-row glow style)

/// Describes a single quick action with an icon, title, color, and an action closure.
private struct QuickActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
}

/// A reusable row of quick actions that always lays out 4 items per row.
private struct QuickActionsRow: View {
    let items: [QuickActionItem]
    @Binding var selectedID: UUID?
    
    // Exactly 4 columns per row across platforms
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(items) { item in
                QuickActionTile(
                    item: item,
                    isSelected: selectedID == item.id,
                    onTap: {
                        selectedID = item.id
                        item.action()
                    }
                )
                .help(item.title)
            }
        }
    }
}

/// A simple, reusable tile for a quick action (icon only).
private struct QuickActionTile: View {
    let item: QuickActionItem
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    #if os(macOS)
    @State private var isHovering = false
    #endif
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    // Icon container
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(item.color.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(item.color.opacity(0.45), lineWidth: 1)
                        )
                        .overlay {
                            if isSelected {
                                // Neon/glow outline layers
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(item.color.opacity(0.9), lineWidth: 2)
                                    .blur(radius: 1.5)
                                    .opacity(0.9)
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(item.color.opacity(0.7), lineWidth: 6)
                                    .blur(radius: 6)
                                    .opacity(0.7)
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(item.color.opacity(0.45), lineWidth: 12)
                                    .blur(radius: 14)
                                    .opacity(0.55)
                            }
                        }
                        .shadow(color: isSelected ? item.color.opacity(0.35) : .clear, radius: isSelected ? 14 : 0, x: 0, y: 0)
                        .shadow(color: isSelected ? item.color.opacity(0.25) : .clear, radius: isSelected ? 24 : 0, x: 0, y: 0)
                        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isSelected)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(item.color)
                        .shadow(color: isSelected ? item.color.opacity(0.5) : .clear, radius: isSelected ? 6 : 0, x: 0, y: 0)
                        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isSelected)
                }
            }
            .padding(6)
            .frame(maxWidth: .infinity, minHeight: 100)
            .scaleEffect(isPressed ? 0.96 : (isSelected ? 1.05 : 1.0))
            #if os(macOS)
            .shadow(color: .black.opacity(isHovering ? 0.10 : 0.0), radius: isHovering ? 6 : 0, x: 0, y: isHovering ? 3 : 0)
            #endif
            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(.plain)
        .pressEvents(
            onPress: { withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { isPressed = true } },
            onRelease: { withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { isPressed = false } }
        )
        #if os(macOS)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovering = hovering
            }
        }
        #endif
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// Small helper to simulate a press animation without relying on custom styles everywhere.
private extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

private struct PressEventsModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

// MARK: - Quick Actions Section (uses new grid and tiles)
struct AccountQuickActionsSection: View {
    let account: Account
    @ObservedObject var viewModel: AccountDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    @State private var selectedID: UUID? = nil
    
    private var items: [QuickActionItem] {
        [
            QuickActionItem(icon: "plus.circle.fill", title: "Add Income", color: DesignTokens.Colors.success) {
                accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                // Add income transaction
            },
            QuickActionItem(icon: "minus.circle.fill", title: "Add Expense", color: DesignTokens.Colors.danger) {
                accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                // Add expense transaction
            },
            QuickActionItem(icon: "arrow.left.arrow.right.circle.fill", title: "Transfer", color: DesignTokens.Colors.tertiary500) {
                accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                // Transfer money
            },
            QuickActionItem(icon: "chart.bar.fill", title: "Analytics", color: DesignTokens.Colors.primary500) {
                accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                // View analytics
            }
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Quick Actions")
                .font(Typography.TextStyle.headlineSmall)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
            
            FinancialCard(shadowLevel: .light) {
                VStack(alignment: .leading, spacing: 16) {
                    QuickActionsRow(items: items, selectedID: $selectedID)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }
            }
        }
    }
}

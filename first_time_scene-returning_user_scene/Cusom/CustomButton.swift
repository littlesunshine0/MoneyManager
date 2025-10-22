//
//  CustomButton.swift
//  MyApp
//
//  Reusable button component with HIG-compliant 44pt minimum touch target

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CustomButton: View {
    enum ButtonStyle {
        case primary
        case secondary
        case text
        case destructive
    }

    let title: String
    let style: ButtonStyle
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var icon: String? = nil

    // Custom initializer aligning with call sites:
    // CustomButton(title: "With Icon", style: .primary, icon: "arrow.right") { ... }
    init(
        title: String,
        style: ButtonStyle,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            guard !isDisabled && !isLoading else { return }

            // Haptic feedback
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }

                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50) // HIG minimum 44pt + padding
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .secondary ? 2 : 0)
            )
        }
        .opacity(isDisabled ? 0.4 : 1.0)
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isLoading ? "Loading" : "")
    }

    // MARK: - Style Properties
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return AppColors.accent
        case .secondary:
            return .clear
        case .text:
            return .clear
        case .destructive:
            return AppColors.error
        }
    }

    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return AppColors.accent
        case .text:
            return AppColors.accent
        }
    }

    private var borderColor: Color {
        style == .secondary ? AppColors.accent : .clear
    }
}

// MARK: - Preview
struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CustomButton(title: "Primary Button", style: .primary) {}
            CustomButton(title: "Secondary Button", style: .secondary) {}
            CustomButton(title: "Text Button", style: .text) {}
            CustomButton(title: "Destructive", style: .destructive) {}
            CustomButton(title: "With Icon", style: .primary, icon: "arrow.right") {}
            CustomButton(title: "Loading", style: .primary, isLoading: true) {}
            CustomButton(title: "Disabled", style: .primary, isDisabled: true) {}
        }
        .padding()
    }
}


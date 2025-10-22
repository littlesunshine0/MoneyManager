//
//  AccessibilityModifiers.swift
//  MyApp
//
//  Reusable accessibility modifiers for VoiceOver and more

import SwiftUI

// MARK: - Accessibility Label with Hint
struct AccessibleLabelModifier: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits?

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits ?? [])
    }
}

extension View {
    /// Add accessibility label and optional hint
    func accessible(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits? = nil
    ) -> some View {
        modifier(AccessibleLabelModifier(label: label, hint: hint, traits: traits))
    }
}

// MARK: - Button Accessibility
extension View {
    /// Mark view as accessible button with proper traits
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }

    /// Mark view as accessible header
    func accessibleHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }

    /// Hide decorative elements from VoiceOver
    func hideFromAccessibility() -> some View {
        self.accessibilityHidden(true)
    }
}

// MARK: - Group Related Content
struct AccessibilityGroupModifier: ViewModifier {
    let label: String?

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label ?? "")
    }
}

extension View {
    /// Group related elements for VoiceOver
    func accessibilityGroup(label: String? = nil) -> some View {
        modifier(AccessibilityGroupModifier(label: label))
    }
}

// MARK: - Dynamic Type Support
struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var textStyle: Font.TextStyle
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        content
            .font(.system(textStyle, design: .default).weight(weight))
    }
}

extension View {
    /// Apply font that scales with Dynamic Type
    func scaledFont(_ textStyle: Font.TextStyle, weight: Font.Weight = .regular) -> some View {
        modifier(ScaledFont(textStyle: textStyle, weight: weight))
    }
}

// MARK: - High Contrast Support
struct HighContrastModifier: ViewModifier {
    @Environment(\.colorSchemeContrast) var contrast
    let normalColor: Color
    let highContrastColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(contrast == .increased ? highContrastColor : normalColor)
    }
}

extension View {
    /// Provide high contrast color variant
    func adaptiveColor(normal: Color, highContrast: Color) -> some View {
        modifier(HighContrastModifier(normalColor: normal, highContrastColor: highContrast))
    }
}

// MARK: - Reduce Motion Support
struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? nil : animation, value: UUID())
    }
}

extension View {
    /// Disable animation when Reduce Motion is enabled
    func respectReduceMotion(_ animation: Animation = .default) -> some View {
        modifier(ReduceMotionModifier(animation: animation))
    }
}

// MARK: - Minimum Touch Target
struct MinimumTouchTarget: ViewModifier {
    let minSize: CGFloat = 44 // HIG minimum

    func body(content: Content) -> some View {
        content
            .frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }
}

extension View {
    /// Ensure view meets HIG minimum 44x44pt touch target
    func minimumTouchTarget() -> some View {
        modifier(MinimumTouchTarget())
    }
}

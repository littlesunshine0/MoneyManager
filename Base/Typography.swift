import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Typography System
public struct Typography {
    
    // MARK: - Font Family Configuration
    public struct FontFamily {
        public static let system = Font.system(.body) // Default to SF Pro
        public static let systemMono = Font.system(.body, design: .monospaced)
        public static let systemRounded = Font.system(.body, design: .rounded)
        
        // Custom font support (if adding custom fonts later)
        public static func custom(_ name: String, size: CGFloat) -> Font {
            return Font.custom(name, size: size)
        }
    }
    
    // MARK: - Font Weight Tokens
    public struct FontWeight {
        public static let ultraLight = Font.Weight.ultraLight
        public static let thin = Font.Weight.thin
        public static let light = Font.Weight.light
        public static let regular = Font.Weight.regular
        public static let medium = Font.Weight.medium
        public static let semibold = Font.Weight.semibold
        public static let bold = Font.Weight.bold
        public static let heavy = Font.Weight.heavy
        public static let black = Font.Weight.black
    }
    
    // MARK: - Base Font Sizes (Reference for Dynamic Type)
    public struct BaseFontSize {
        public static let caption2: CGFloat = 11
        public static let caption1: CGFloat = 12
        public static let footnote: CGFloat = 13
        public static let subheadline: CGFloat = 15
        public static let callout: CGFloat = 16
        public static let body: CGFloat = 17        // Base size for Dynamic Type
        public static let headline: CGFloat = 17
        public static let title3: CGFloat = 20
        public static let title2: CGFloat = 22
        public static let title1: CGFloat = 28
        public static let largeTitle: CGFloat = 34
        
        // Financial-specific sizes
        public static let currencyLarge: CGFloat = 32
        public static let currencyMedium: CGFloat = 24
        public static let currencySmall: CGFloat = 16
        public static let accountBalance: CGFloat = 28
        public static let transactionAmount: CGFloat = 20
    }
    
    // MARK: - Line Height Tokens
    public struct LineHeight {
        public static let tight: CGFloat = 1.2
        public static let normal: CGFloat = 1.4
        public static let relaxed: CGFloat = 1.6
        public static let loose: CGFloat = 1.8
    }
    
    // MARK: - Letter Spacing Tokens
    public struct LetterSpacing {
        public static let tight: CGFloat = -0.5
        public static let normal: CGFloat = 0
        public static let relaxed: CGFloat = 0.5
        public static let wide: CGFloat = 1.0
    }
    
    // MARK: - Text Styles (Semantic)
    public struct TextStyle {
        
        // MARK: - Display Text (Large headings)
        public static let displayLarge = Font.system(size: 57, weight: .regular, design: .default)
        public static let displayMedium = Font.system(size: 45, weight: .regular, design: .default)
        public static let displaySmall = Font.system(size: 36, weight: .regular, design: .default)
        
        // MARK: - Headlines
        public static let headlineLarge = Font.system(size: 32, weight: .regular, design: .default)
        public static let headlineMedium = Font.system(size: 28, weight: .regular, design: .default)
        public static let headlineSmall = Font.system(size: 24, weight: .regular, design: .default)
        
        // MARK: - Titles
        public static let titleLarge = Font.system(size: 22, weight: .regular, design: .default)
        public static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)
        public static let titleSmall = Font.system(size: 14, weight: .medium, design: .default)
        
        // MARK: - Labels
        public static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
        public static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
        public static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
        
        // MARK: - Body Text
        public static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        public static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
        public static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
        
        // MARK: - Financial-Specific Styles
        public static let currencyDisplay = Font.system(size: 32, weight: .semibold, design: .rounded)
        public static let currencyLarge = Font.system(size: 24, weight: .semibold, design: .rounded)
        public static let currencyMedium = Font.system(size: 20, weight: .medium, design: .rounded)
        public static let currencySmall = Font.system(size: 16, weight: .medium, design: .rounded)
        public static let currencyCaption = Font.system(size: 12, weight: .regular, design: .rounded)
        
        public static let accountName = Font.system(size: 16, weight: .medium, design: .default)
        public static let accountBalance = Font.system(size: 20, weight: .semibold, design: .rounded)
        public static let transactionTitle = Font.system(size: 16, weight: .medium, design: .default)
        public static let transactionAmount = Font.system(size: 16, weight: .semibold, design: .rounded)
        public static let transactionDate = Font.system(size: 12, weight: .regular, design: .default)
        public static let categoryLabel = Font.system(size: 12, weight: .medium, design: .default)
        
        // MARK: - Interface Elements
        public static let buttonText = Font.system(size: 16, weight: .semibold, design: .default)
        public static let tabBarText = Font.system(size: 10, weight: .medium, design: .default)
        public static let navigationTitle = Font.system(size: 17, weight: .semibold, design: .default)
        public static let sectionHeader = Font.system(size: 13, weight: .regular, design: .default)
    }
}

// MARK: - Dynamic Type Support
public struct DynamicTypography {
    
    // MARK: - Dynamic Type Scaling Functions
    public static func scaledFont(for textStyle: Font.TextStyle, baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Use explicit size so we can consistently apply weight
        return Font.system(size: baseSize, weight: weight, design: .default)
    }
    
    public static func scaledCustomFont(name: String, textStyle: Font.TextStyle, baseSize: CGFloat) -> Font {
        #if canImport(UIKit)
        let scaledSize = UIFontMetrics(forTextStyle: UIFont.TextStyle.from(textStyle)).scaledValue(for: baseSize)
        return Font.custom(name, size: scaledSize)
        #else
        return Font.custom(name, size: baseSize)
        #endif
    }
    
    // MARK: - Financial-Specific Dynamic Fonts
    public static func currencyFont(for amount: Double, style: CurrencyDisplayStyle = .medium) -> Font {
        switch style {
        case .display:
            return scaledFont(for: .largeTitle, baseSize: Typography.BaseFontSize.currencyLarge, weight: .semibold)
        case .large:
            return scaledFont(for: .title, baseSize: Typography.BaseFontSize.currencyMedium, weight: .semibold)
        case .medium:
            return scaledFont(for: .headline, baseSize: Typography.BaseFontSize.transactionAmount, weight: .medium)
        case .small:
            return scaledFont(for: .body, baseSize: Typography.BaseFontSize.currencySmall, weight: .medium)
        case .caption:
            return scaledFont(for: .caption, baseSize: Typography.BaseFontSize.caption1, weight: .regular)
        }
    }
}

// MARK: - Currency Display Style
public enum CurrencyDisplayStyle {
    case display    // Large dashboard amounts
    case large      // Account balances
    case medium     // Transaction amounts
    case small      // Inline amounts
    case caption    // Small references
}

// MARK: - Text Modifiers
public struct TextModifiers {
    
    // MARK: - Financial Amount Modifier
    public struct CurrencyText: ViewModifier {
        let amount: Double
        let style: CurrencyDisplayStyle
        let color: Color?
        
        public init(amount: Double, style: CurrencyDisplayStyle = .medium, color: Color? = nil) {
            self.amount = amount
            self.style = style
            self.color = color
        }
        
        public func body(content: Content) -> some View {
            content
                .font(DynamicTypography.currencyFont(for: amount, style: style))
                .foregroundColor(color ?? determineAmountColor(amount))
                .monospacedDigit() // Ensures consistent digit spacing
                .accessibilityLabel(formatAmountForAccessibility(amount))
        }
        
        private func determineAmountColor(_ amount: Double) -> Color {
            if amount > 0 {
                return DesignTokens.Colors.success
            } else if amount < 0 {
                return DesignTokens.Colors.danger
            } else {
                return DesignTokens.Colors.textPrimary
            }
        }
        
        private func formatAmountForAccessibility(_ amount: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD" // This should come from user settings
            return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
        }
    }
    
    // MARK: - Responsive Text Modifier
    public struct ResponsiveText: ViewModifier {
        let textStyle: Font.TextStyle
        let weight: Font.Weight
        let color: Color?
        
        public init(_ textStyle: Font.TextStyle, weight: Font.Weight = .regular, color: Color? = nil) {
            self.textStyle = textStyle
            self.weight = weight
            self.color = color
        }
        
        public func body(content: Content) -> some View {
            content
                .font(.system(size: sizeFor(textStyle), weight: weight, design: .default))
                .foregroundColor(color)
                .dynamicTypeSize(.accessibility1...DynamicTypeSize.accessibility5) // Support full range
        }
        
        private func sizeFor(_ style: Font.TextStyle) -> CGFloat {
            switch style {
            case .largeTitle: return Typography.BaseFontSize.largeTitle
            case .title: return Typography.BaseFontSize.title1
            case .title2: return Typography.BaseFontSize.title2
            case .title3: return Typography.BaseFontSize.title3
            case .headline: return Typography.BaseFontSize.headline
            case .subheadline: return Typography.BaseFontSize.subheadline
            case .body: return Typography.BaseFontSize.body
            case .callout: return Typography.BaseFontSize.callout
            case .footnote: return Typography.BaseFontSize.footnote
            case .caption: return Typography.BaseFontSize.caption1
            case .caption2: return Typography.BaseFontSize.caption2
            @unknown default: return Typography.BaseFontSize.body
            }
        }
    }
    
    // MARK: - Financial Category Label Modifier
    public struct CategoryLabel: ViewModifier {
        let category: String
        let color: Color
        
        public func body(content: Content) -> some View {
            content
                .font(Typography.TextStyle.categoryLabel)
                .padding(.horizontal, DesignTokens.Spacing.xs)
                .padding(.vertical, DesignTokens.Spacing.xxxs)
                .background(color.opacity(0.1))
                .foregroundColor(color)
                .clipShape(Capsule())
        }
    }
}

// MARK: - SwiftUI View Extensions
extension View {
    
    // MARK: - Typography Modifiers
    public func currencyText(amount: Double, style: CurrencyDisplayStyle = .medium, color: Color? = nil) -> some View {
        modifier(TextModifiers.CurrencyText(amount: amount, style: style, color: color))
    }
    
    public func responsiveText(_ textStyle: Font.TextStyle, weight: Font.Weight = .regular, color: Color? = nil) -> some View {
        modifier(TextModifiers.ResponsiveText(textStyle, weight: weight, color: color))
    }
    
    public func categoryLabel(category: String, color: Color) -> some View {
        modifier(TextModifiers.CategoryLabel(category: category, color: color))
    }
    
    // MARK: - Text Style Shortcuts
    public func displayText(weight: Font.Weight = .regular) -> some View {
        font(.system(size: Typography.BaseFontSize.largeTitle, weight: weight, design: .default))
    }
    
    public func headlineText(weight: Font.Weight = .semibold) -> some View {
        font(.system(size: Typography.BaseFontSize.headline, weight: weight, design: .default))
    }
    
    public func bodyText(weight: Font.Weight = .regular) -> some View {
        font(.system(size: Typography.BaseFontSize.body, weight: weight, design: .default))
    }
    
    public func captionText(weight: Font.Weight = .regular) -> some View {
        font(.system(size: Typography.BaseFontSize.caption1, weight: weight, design: .default))
    }
    
    public func buttonText() -> some View {
        font(Typography.TextStyle.buttonText)
    }
}

#if canImport(UIKit)
// MARK: - Helper Extensions (UIKit)
extension UIFont.TextStyle {
    static func from(_ textStyle: Font.TextStyle) -> UIFont.TextStyle {
        switch textStyle {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
#endif

// MARK: - Accessibility Support
public struct AccessibleTypography {
    
    // MARK: - Dynamic Type Size Handling
    public static func adjustedFont(for dynamicTypeSize: DynamicTypeSize, baseFont: Font) -> Font {
        switch dynamicTypeSize {
        case .xSmall, .small:
            return baseFont
        case .medium, .large:
            return baseFont
        case .xLarge, .xxLarge, .xxxLarge:
            return baseFont.weight(.medium) // Slightly heavier for better readability
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return baseFont.weight(.semibold) // Much heavier for accessibility
        @unknown default:
            return baseFont
        }
    }
    
    // MARK: - High Contrast Typography Adjustments
    public static func highContrastFont(_ baseFont: Font) -> Font {
        return baseFont.weight(.semibold) // Increase weight for better visibility
    }
    
    // MARK: - VoiceOver Optimizations
    public static func accessibilityDescription(for amount: Double, context: String = "") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let amountString = formatter.string(from: NSNumber(value: abs(amount))) ?? "$\(abs(amount))"
        let sign = amount < 0 ? "negative" : amount > 0 ? "positive" : ""
        
        if context.isEmpty {
            return "\(sign) \(amountString)".trimmingCharacters(in: .whitespaces)
        } else {
            return "\(context): \(sign) \(amountString)".trimmingCharacters(in: .whitespaces)
        }
    }
}

#if DEBUG
// MARK: - Typography Preview
struct Typography_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Standard typography preview
            TypographyPreviewView()
                .previewDisplayName("Typography System")
            
            // Dynamic type preview (extra large)
            TypographyPreviewView()
                .environment(\.dynamicTypeSize, .xLarge)
                .previewDisplayName("Dynamic Type - XL")
            
            // Accessibility size preview
            TypographyPreviewView()
                .environment(\.dynamicTypeSize, .accessibility2)
                .previewDisplayName("Accessibility Type")
        }
    }
}

struct TypographyPreviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                
                // Display Text
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Display Styles")
                        .font(.headline)
                    
                    Text("Display Large")
                        .font(Typography.TextStyle.displayLarge)
                    Text("Display Medium")
                        .font(Typography.TextStyle.displayMedium)
                    Text("Display Small")
                        .font(Typography.TextStyle.displaySmall)
                }
                
                Divider()
                
                // Financial Typography
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Financial Typography")
                        .font(.headline)
                    
                    HStack {
                        Text("$1,234.56")
                            .currencyText(amount: 1234.56, style: .display)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Account Balance:")
                            .font(Typography.TextStyle.accountName)
                        Spacer()
                        Text("$12,345.67")
                            .currencyText(amount: 12345.67, style: .large)
                    }
                    
                    HStack {
                        Text("Coffee Shop")
                            .font(Typography.TextStyle.transactionTitle)
                        Spacer()
                        Text("-$4.50")
                            .currencyText(amount: -4.50, style: .medium)
                    }
                    
                    Text("Food")
                        .categoryLabel(category: "Food", color: DesignTokens.Colors.tertiary500)
                }
                
                Divider()
                
                // Text Hierarchy
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Text Hierarchy")
                        .font(.headline)
                    
                    Text("Headline Large")
                        .font(Typography.TextStyle.headlineLarge)
                    Text("Title Large")
                        .font(Typography.TextStyle.titleLarge)
                    Text("Body Large - This is regular body text that should be easy to read.")
                        .font(Typography.TextStyle.bodyLarge)
                    Text("Label Medium")
                        .font(Typography.TextStyle.labelMedium)
                    Text("Caption text for supplementary information")
                        .font(Typography.TextStyle.bodySmall)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Interactive Elements
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Interactive Elements")
                        .font(.headline)
                    
                    Button("Primary Button") {}
                        .buttonText()
                        .padding()
                        .background(DesignTokens.Colors.primary500)
                        .foregroundColor(.white)
                        .cornerRadius(DesignTokens.BorderRadius.button)
                }
                
                Spacer()
            }
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle("Typography")
        #if canImport(UIKit)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
#endif

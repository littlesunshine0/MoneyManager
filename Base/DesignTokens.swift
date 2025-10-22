import SwiftUI
import Foundation

// MARK: - Design Tokens Foundation
// Core atomic values that power the entire design system

public struct DesignTokens {
    
    // MARK: - Color Tokens
    public struct Colors {
        
        // MARK: - Primary Brand Colors
        public static let primary50 = Color(red: 0.98, green: 0.99, blue: 1.00)   // #FBFCFF
        public static let primary100 = Color(red: 0.93, green: 0.96, blue: 1.00)  // #EDF5FF
        public static let primary200 = Color(red: 0.85, green: 0.91, blue: 1.00)  // #D9E8FF
        public static let primary300 = Color(red: 0.69, green: 0.81, blue: 1.00)  // #B0CFFF
        public static let primary400 = Color(red: 0.47, green: 0.67, blue: 1.00)  // #78ABFF
        public static let primary500 = Color(red: 0.22, green: 0.51, blue: 1.00)  // #3882FF - Primary
        public static let primary600 = Color(red: 0.16, green: 0.42, blue: 0.89)  // #296BE3
        public static let primary700 = Color(red: 0.12, green: 0.34, blue: 0.76)  // #1F56C2
        public static let primary800 = Color(red: 0.09, green: 0.28, blue: 0.64)  // #1747A3
        public static let primary900 = Color(red: 0.06, green: 0.21, blue: 0.51)  // #0F3682
        
        // MARK: - Secondary Colors (Financial Green)
        public static let secondary50 = Color(red: 0.97, green: 1.00, blue: 0.98)   // #F7FFF9
        public static let secondary100 = Color(red: 0.91, green: 1.00, blue: 0.94)  // #E8FFF0
        public static let secondary200 = Color(red: 0.80, green: 1.00, blue: 0.87)  // #CCFFDD
        public static let secondary300 = Color(red: 0.60, green: 0.98, blue: 0.75)  // #99F7BF
        public static let secondary400 = Color(red: 0.33, green: 0.91, blue: 0.58)  // #54E894
        public static let secondary500 = Color(red: 0.08, green: 0.80, blue: 0.40)  // #14CC66 - Success Green
        public static let secondary600 = Color(red: 0.06, green: 0.69, blue: 0.33)  // #0FB054
        public static let secondary700 = Color(red: 0.05, green: 0.58, blue: 0.28)  // #0D9447
        public static let secondary800 = Color(red: 0.04, green: 0.47, blue: 0.23)  // #0A783A
        public static let secondary900 = Color(red: 0.03, green: 0.36, blue: 0.18)  // #085C2E
        
        // MARK: - Tertiary Colors (Accent Orange)
        public static let tertiary50 = Color(red: 1.00, green: 0.99, blue: 0.97)    // #FFFCF7
        public static let tertiary100 = Color(red: 1.00, green: 0.97, blue: 0.89)   // #FFF7E5
        public static let tertiary200 = Color(red: 1.00, green: 0.92, blue: 0.75)   // #FFECBF
        public static let tertiary300 = Color(red: 1.00, green: 0.85, blue: 0.52)   // #FFD985
        public static let tertiary400 = Color(red: 1.00, green: 0.76, blue: 0.24)   // #FFC23D
        public static let tertiary500 = Color(red: 0.96, green: 0.65, blue: 0.00)   // #F5A500 - Warning Orange
        public static let tertiary600 = Color(red: 0.82, green: 0.54, blue: 0.00)   // #D18A00
        public static let tertiary700 = Color(red: 0.69, green: 0.44, blue: 0.00)   // #B07000
        public static let tertiary800 = Color(red: 0.56, green: 0.36, blue: 0.00)   // #8F5B00
        public static let tertiary900 = Color(red: 0.43, green: 0.28, blue: 0.00)   // #6E4700
        
        // MARK: - Error Colors (Financial Red)
        public static let error50 = Color(red: 1.00, green: 0.98, blue: 0.98)     // #FFF9F9
        public static let error100 = Color(red: 1.00, green: 0.93, blue: 0.93)    // #FFEDEE
        public static let error200 = Color(red: 1.00, green: 0.85, blue: 0.86)    // #FFD9DC
        public static let error300 = Color(red: 1.00, green: 0.69, blue: 0.72)    // #FFB0B8
        public static let error400 = Color(red: 1.00, green: 0.47, blue: 0.52)    // #FF7885
        public static let error500 = Color(red: 0.94, green: 0.24, blue: 0.31)    // #F03D4F - Error Red
        public static let error600 = Color(red: 0.80, green: 0.18, blue: 0.24)    // #CC2E3D
        public static let error700 = Color(red: 0.67, green: 0.14, blue: 0.19)    // #AB242F
        public static let error800 = Color(red: 0.55, green: 0.12, blue: 0.16)    // #8C1F26
        public static let error900 = Color(red: 0.42, green: 0.09, blue: 0.12)    // #6B171D
        
        // MARK: - Neutral/Gray Colors
        public static let neutral0 = Color.white                                   // #FFFFFF
        public static let neutral50 = Color(red: 0.98, green: 0.99, blue: 0.99)   // #FAFBFC
        public static let neutral100 = Color(red: 0.95, green: 0.96, blue: 0.97)  // #F2F4F7
        public static let neutral200 = Color(red: 0.91, green: 0.93, blue: 0.94)  // #E8EBEF
        public static let neutral300 = Color(red: 0.82, green: 0.85, blue: 0.88)  // #D1D6E0
        public static let neutral400 = Color(red: 0.68, green: 0.73, blue: 0.78)  // #ADBACC
        public static let neutral500 = Color(red: 0.50, green: 0.56, blue: 0.64)  // #8090A3
        public static let neutral600 = Color(red: 0.38, green: 0.44, blue: 0.52)  // #627085
        public static let neutral700 = Color(red: 0.28, green: 0.33, blue: 0.40)  // #485566
        public static let neutral800 = Color(red: 0.19, green: 0.23, blue: 0.29)  // #303B47
        public static let neutral900 = Color(red: 0.11, green: 0.15, blue: 0.20)  // #1C2633
        public static let neutral1000 = Color.black                               // #000000
    }
    
    // MARK: - Spacing Tokens (4px base unit)
    public struct Spacing {
        public static let xxxs: CGFloat = 2    // 2px
        public static let xxs: CGFloat = 4     // 4px
        public static let xs: CGFloat = 8      // 8px
        public static let sm: CGFloat = 12     // 12px
        public static let md: CGFloat = 16     // 16px - Base unit
        public static let lg: CGFloat = 20     // 20px
        public static let xl: CGFloat = 24     // 24px
        public static let xxl: CGFloat = 32    // 32px
        public static let xxxl: CGFloat = 40   // 40px
        public static let huge: CGFloat = 48   // 48px
        public static let massive: CGFloat = 64 // 64px
        
        // MARK: - Component-specific spacing
        public static let buttonPaddingVertical: CGFloat = 12
        public static let buttonPaddingHorizontal: CGFloat = 20
        public static let cardPadding: CGFloat = 16
        public static let sectionSpacing: CGFloat = 24
        public static let screenMargins: CGFloat = 16
    }
    
    // MARK: - Border Radius Tokens (Including Deep Squircle)
    public struct BorderRadius {
        public static let none: CGFloat = 0
        public static let xs: CGFloat = 2
        public static let sm: CGFloat = 4
        public static let md: CGFloat = 8     // Standard radius
        public static let lg: CGFloat = 12
        public static let xl: CGFloat = 16
        public static let xxl: CGFloat = 20
        public static let circle: CGFloat = 9999 // Perfect circle
        
        // MARK: - Brand-specific radii
        public static let button: CGFloat = 8
        public static let card: CGFloat = 12
        public static let modal: CGFloat = 16
        public static let deepSquircle: CGFloat = 20 // Your signature brand shape
    }
    
    // MARK: - Shadow Tokens
    public struct Shadow {
        public static let none = (offset: CGSize.zero, blur: CGFloat(0.0), opacity: 0.0)
        
        public static let xs = (
            offset: CGSize(width: 0, height: 1),
            blur: CGFloat(2.0),
            opacity: 0.05
        )
        
        public static let sm = (
            offset: CGSize(width: 0, height: 1),
            blur: CGFloat(3.0),
            opacity: 0.1
        )
        
        public static let md = (
            offset: CGSize(width: 0, height: 4),
            blur: CGFloat(6.0),
            opacity: 0.1
        )
        
        public static let lg = (
            offset: CGSize(width: 0, height: 10),
            blur: CGFloat(15.0),
            opacity: 0.1
        )
        
        public static let xl = (
            offset: CGSize(width: 0, height: 20),
            blur: CGFloat(25.0),
            opacity: 0.1
        )
        
        public static let xxl = (
            offset: CGSize(width: 0, height: 25),
            blur: CGFloat(50.0),
            opacity: 0.15
        )
    }
    
    // MARK: - Opacity Tokens
    public struct Opacity {
        public static let transparent: Double = 0.0
        public static let subtle: Double = 0.05
        public static let light: Double = 0.1
        public static let medium: Double = 0.2
        public static let strong: Double = 0.4
        public static let intense: Double = 0.6
        public static let heavy: Double = 0.8
        public static let opaque: Double = 1.0
        
        // MARK: - Component-specific opacity
        public static let disabled: Double = 0.4
        public static let pressed: Double = 0.8
        public static let overlay: Double = 0.6
        public static let backdrop: Double = 0.3
    }
    
    // MARK: - Border Width Tokens
    public struct BorderWidth {
        public static let none: CGFloat = 0
        public static let hairline: CGFloat = 0.5
        public static let thin: CGFloat = 1
        public static let medium: CGFloat = 2
        public static let thick: CGFloat = 4
        public static let heavy: CGFloat = 8
    }
    
    // MARK: - Icon Size Tokens
    public struct IconSize {
        public static let xs: CGFloat = 12
        public static let sm: CGFloat = 16
        public static let md: CGFloat = 20    // Standard icon size
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
        public static let huge: CGFloat = 64
        
        // MARK: - Context-specific sizes
        public static let toolbar: CGFloat = 20
        public static let pane: CGFloat = 16
        public static let dock: CGFloat = 24
        public static let app: CGFloat = 32
    }
    
    // MARK: - Z-Index Tokens
    public struct ZIndex {
        public static let base: Double = 0
        public static let raised: Double = 1
        public static let floating: Double = 10
        public static let overlay: Double = 100
        public static let modal: Double = 1000
        public static let toast: Double = 1100
        public static let tooltip: Double = 1200
        public static let dropdown: Double = 1300
        public static let popover: Double = 1400
        public static let max: Double = 9999
    }
}

// MARK: - Convenience Extensions
extension DesignTokens.Colors {
    
    // MARK: - Semantic Color Aliases
    public static let success = secondary500
    public static let warning = tertiary500
    public static let danger = error500
    public static let info = primary500
    
    // MARK: - Text Colors
    public static let textPrimary = neutral900
    public static let textSecondary = neutral700
    public static let textTertiary = neutral500
    public static let textQuaternary = neutral400
    public static let textInverse = neutral0
    public static let textDisabled = neutral400
    
    // MARK: - Background Colors
    public static let backgroundPrimary = neutral0
    public static let backgroundSecondary = neutral50
    public static let backgroundTertiary = neutral100
    public static let backgroundInverse = neutral900
    public static let backgroundOverlay = neutral900.opacity(0.6)
    
    // MARK: - Border Colors
    public static let borderPrimary = neutral300
    public static let borderSecondary = neutral200
    public static let borderTertiary = neutral100
    public static let borderFocus = primary500
    public static let borderError = error500
}

// MARK: - SwiftUI View Extensions for Token Application
extension View {
    
    // MARK: - Spacing Helpers
    public func paddingToken(_ token: CGFloat) -> some View {
        padding(token)
    }
    
    public func paddingHorizontalToken(_ token: CGFloat) -> some View {
        padding(.horizontal, token)
    }
    
    public func paddingVerticalToken(_ token: CGFloat) -> some View {
        padding(.vertical, token)
    }
    
    // MARK: - Corner Radius Helpers
    public func cornerRadiusToken(_ token: CGFloat) -> some View {
        cornerRadius(token)
    }
    
    // MARK: - Shadow Helpers
    public func shadowToken(_ shadow: (offset: CGSize, blur: CGFloat, opacity: Double)) -> some View {
        self.shadow(
            color: Color.black.opacity(shadow.opacity),
            radius: shadow.blur / 2,
            x: shadow.offset.width,
            y: shadow.offset.height
        )
    }
    
    // MARK: - Border Helpers
    public func borderToken(width: CGFloat, color: Color) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
                .stroke(color, lineWidth: width)
        )
    }
}

#if DEBUG
// MARK: - Preview Provider for Design Tokens
struct DesignTokens_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                
                // Color Tokens Preview
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Primary Colors")
                        .font(.headline)
                    
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        ForEach([
                            ("50", DesignTokens.Colors.primary50),
                            ("100", DesignTokens.Colors.primary100),
                            ("200", DesignTokens.Colors.primary200),
                            ("300", DesignTokens.Colors.primary300),
                            ("400", DesignTokens.Colors.primary400),
                            ("500", DesignTokens.Colors.primary500),
                        ], id: \.0) { name, color in
                            VStack {
                                RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                Text(name)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                
                // Spacing Tokens Preview
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Spacing Tokens")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        ForEach([
                            ("xs", DesignTokens.Spacing.xs),
                            ("sm", DesignTokens.Spacing.sm),
                            ("md", DesignTokens.Spacing.md),
                            ("lg", DesignTokens.Spacing.lg),
                            ("xl", DesignTokens.Spacing.xl),
                            ("xxl", DesignTokens.Spacing.xxl),
                        ], id: \.0) { name, spacing in
                            HStack {
                                Text(name)
                                    .frame(width: 40, alignment: .leading)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(DesignTokens.Colors.primary500)
                                    .frame(width: spacing, height: 16)
                                Text("\(Int(spacing))px")
                                    .font(.caption)
                                Spacer()
                            }
                        }
                    }
                }
                
                // Border Radius Preview
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Border Radius")
                        .font(.headline)
                    
                    HStack(spacing: DesignTokens.Spacing.md) {
                        ForEach([
                            ("sm", DesignTokens.BorderRadius.sm),
                            ("md", DesignTokens.BorderRadius.md),
                            ("lg", DesignTokens.BorderRadius.lg),
                            ("xl", DesignTokens.BorderRadius.xl),
                            ("squircle", DesignTokens.BorderRadius.deepSquircle),
                        ], id: \.0) { name, radius in
                            VStack {
                                RoundedRectangle(cornerRadius: radius)
                                    .fill(DesignTokens.Colors.secondary500)
                                    .frame(width: 50, height: 50)
                                Text(name)
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .paddingToken(DesignTokens.Spacing.md)
        }
        .previewDisplayName("Design Tokens")
    }
}
#endif

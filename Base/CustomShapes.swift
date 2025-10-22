import SwiftUI
import Foundation

// MARK: - Custom Shapes System
public struct CustomShapes {
    
    // MARK: - Brand Shapes (Your signature elements)
    
    /// Deep Squircle - Your primary brand shape
    /// A smooth rounded rectangle that's more organic than standard corner radius
    public struct DeepSquircle: Shape {
        private let cornerRadius: CGFloat
        private let smoothness: CGFloat
        
        public init(cornerRadius: CGFloat = DesignTokens.BorderRadius.deepSquircle, smoothness: CGFloat = 0.6) {
            self.cornerRadius = cornerRadius
            self.smoothness = smoothness
        }
        
        public func path(in rect: CGRect) -> Path {
            let minDimension = min(rect.width, rect.height)
            let actualRadius = min(cornerRadius, minDimension / 2)
            let smoothRadius = actualRadius * smoothness
            
            return Path { path in
                // Start from top-left, moving clockwise
                let topLeft = CGPoint(x: rect.minX, y: rect.minY + actualRadius)
                path.move(to: topLeft)
                
                // Top-left corner
                path.addQuadCurve(
                    to: CGPoint(x: rect.minX + actualRadius, y: rect.minY),
                    control: CGPoint(x: rect.minX, y: rect.minY + smoothRadius)
                )
                
                // Top edge
                path.addLine(to: CGPoint(x: rect.maxX - actualRadius, y: rect.minY))
                
                // Top-right corner
                path.addQuadCurve(
                    to: CGPoint(x: rect.maxX, y: rect.minY + actualRadius),
                    control: CGPoint(x: rect.maxX, y: rect.minY + smoothRadius)
                )
                
                // Right edge
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - actualRadius))
                
                // Bottom-right corner
                path.addQuadCurve(
                    to: CGPoint(x: rect.maxX - actualRadius, y: rect.maxY),
                    control: CGPoint(x: rect.maxX, y: rect.maxY - smoothRadius)
                )
                
                // Bottom edge
                path.addLine(to: CGPoint(x: rect.minX + actualRadius, y: rect.maxY))
                
                // Bottom-left corner
                path.addQuadCurve(
                    to: CGPoint(x: rect.minX, y: rect.maxY - actualRadius),
                    control: CGPoint(x: rect.minX, y: rect.maxY - smoothRadius)
                )
                
                // Close the path
                path.closeSubpath()
            }
        }
    }
    
    // MARK: - Financial Shapes
    
    /// Rounded Bar Shape - For budget progress indicators
    public struct RoundedBar: Shape {
        private let cornerRadius: CGFloat
        
        public init(cornerRadius: CGFloat = DesignTokens.BorderRadius.sm) {
            self.cornerRadius = cornerRadius
        }
        
        public func path(in rect: CGRect) -> Path {
            Path { path in
                path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
            }
        }
    }
    
    /// Progress Ring - For savings goals and budget completion
    public struct ProgressRing: Shape {
        private let progress: Double
        private let thickness: CGFloat
        private let startAngle: Angle
        
        public init(progress: Double, thickness: CGFloat = 8, startAngle: Angle = .degrees(-90)) {
            self.progress = max(0, min(1, progress))
            self.thickness = thickness
            self.startAngle = startAngle
        }
        
        public func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2 - thickness / 2
            let endAngle = startAngle + .degrees(360 * progress)
            
            return Path { path in
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
            }
        }
    }
    
    /// Card Shape - For financial cards with subtle corners
    public struct CardShape: Shape {
        private let cornerRadius: CGFloat
        
        public init(cornerRadius: CGFloat = DesignTokens.BorderRadius.card) {
            self.cornerRadius = cornerRadius
        }
        
        public func path(in rect: CGRect) -> Path {
            Path { path in
                path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
            }
        }
    }
    
    /// Chevron Shape - For navigation and hierarchy
    public struct ChevronShape: Shape {
        public enum Direction {
            case up, down, left, right
        }
        
        private let direction: Direction
        private let strokeWidth: CGFloat
        
        public init(direction: Direction, strokeWidth: CGFloat = 2) {
            self.direction = direction
            self.strokeWidth = strokeWidth
        }
        
        public func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let size = min(rect.width, rect.height) * 0.4
            
            return Path { path in
                switch direction {
                case .up:
                    path.move(to: CGPoint(x: center.x - size, y: center.y + size/2))
                    path.addLine(to: CGPoint(x: center.x, y: center.y - size/2))
                    path.addLine(to: CGPoint(x: center.x + size, y: center.y + size/2))
                    
                case .down:
                    path.move(to: CGPoint(x: center.x - size, y: center.y - size/2))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + size/2))
                    path.addLine(to: CGPoint(x: center.x + size, y: center.y - size/2))
                    
                case .left:
                    path.move(to: CGPoint(x: center.x + size/2, y: center.y - size))
                    path.addLine(to: CGPoint(x: center.x - size/2, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + size/2, y: center.y + size))
                    
                case .right:
                    path.move(to: CGPoint(x: center.x - size/2, y: center.y - size))
                    path.addLine(to: CGPoint(x: center.x + size/2, y: center.y))
                    path.addLine(to: CGPoint(x: center.x - size/2, y: center.y + size))
                }
            }
        }
    }
}

// MARK: - Vector Icon Shapes
public struct VectorIcons {
    
    /// Custom Money Symbol
    public struct MoneySymbol: Shape {
        public func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) * 0.4
            
            return Path { path in
                // Outer circle
                path.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
                
                // Dollar sign - vertical line
                path.move(to: CGPoint(x: center.x, y: center.y - radius * 0.8))
                path.addLine(to: CGPoint(x: center.x, y: center.y + radius * 0.8))
                
                // S curve
                let curveRadius = radius * 0.3
                path.move(to: CGPoint(x: center.x + curveRadius, y: center.y - curveRadius))
                path.addQuadCurve(
                    to: CGPoint(x: center.x - curveRadius, y: center.y),
                    control: CGPoint(x: center.x - curveRadius, y: center.y - curveRadius)
                )
                path.addQuadCurve(
                    to: CGPoint(x: center.x + curveRadius, y: center.y + curveRadius),
                    control: CGPoint(x: center.x + curveRadius, y: center.y)
                )
            }
        }
    }
    
    /// Custom Wallet Shape
    public struct WalletShape: Shape {
        public func path(in rect: CGRect) -> Path {
            let cornerRadius: CGFloat = 4
            let flapHeight: CGFloat = rect.height * 0.15
            
            return Path { path in
                // Main wallet body
                path.addRoundedRect(
                    in: CGRect(x: rect.minX, y: rect.minY + flapHeight, width: rect.width, height: rect.height - flapHeight),
                    cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
                )
                
                // Wallet flap
                path.addRoundedRect(
                    in: CGRect(x: rect.minX + rect.width * 0.1, y: rect.minY, width: rect.width * 0.8, height: flapHeight + cornerRadius),
                    cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
                )
            }
        }
    }
    
    /// Custom Chart Bar Shape
    public struct ChartBar: Shape {
        private let values: [Double]
        private let maxValue: Double
        
        public init(values: [Double]) {
            self.values = values
            self.maxValue = values.max() ?? 1.0
        }
        
        public func path(in rect: CGRect) -> Path {
            guard !values.isEmpty else { return Path() }
            
            let barWidth = rect.width / CGFloat(values.count) * 0.8
            let spacing = rect.width / CGFloat(values.count) * 0.2
            
            return Path { path in
                for (index, value) in values.enumerated() {
                    let normalizedValue = value / maxValue
                    let barHeight = rect.height * normalizedValue
                    let x = CGFloat(index) * (barWidth + spacing) + spacing / 2
                    let y = rect.maxY - barHeight
                    
                    path.addRoundedRect(
                        in: CGRect(x: x, y: y, width: barWidth, height: barHeight),
                        cornerSize: CGSize(width: 2, height: 2)
                    )
                }
            }
        }
    }
}

// MARK: - Shape Modifiers and Extensions
extension View {
    
    // MARK: - Brand Shape Modifiers
    
    /// Apply the signature deep squircle shape
    public func deepSquircleBorder(lineWidth: CGFloat = 1, color: Color = DesignTokens.Colors.borderPrimary) -> some View {
        self.overlay(
            CustomShapes.DeepSquircle()
                .stroke(color, lineWidth: lineWidth)
        )
    }
    
    /// Clip to deep squircle shape
    public func deepSquircleClip(cornerRadius: CGFloat = DesignTokens.BorderRadius.deepSquircle) -> some View {
        self.clipShape(CustomShapes.DeepSquircle(cornerRadius: cornerRadius))
    }
    
    /// Apply deep squircle background
    public func deepSquircleBackground(_ color: Color) -> some View {
        self.background(
            CustomShapes.DeepSquircle()
                .fill(color)
        )
    }
    
    // MARK: - Card Shape Modifiers
    
    public func cardShape(cornerRadius: CGFloat = DesignTokens.BorderRadius.card) -> some View {
        self.clipShape(CustomShapes.CardShape(cornerRadius: cornerRadius))
    }
    
    public func cardBorder(lineWidth: CGFloat = 1, color: Color = DesignTokens.Colors.borderSecondary) -> some View {
        self.overlay(
            CustomShapes.CardShape()
                .stroke(color, lineWidth: lineWidth)
        )
    }
    
    public func cardBackground(_ color: Color, cornerRadius: CGFloat = DesignTokens.BorderRadius.card) -> some View {
        self.background(
            CustomShapes.CardShape(cornerRadius: cornerRadius)
                .fill(color)
        )
    }
    
    // MARK: - Progress Shape Modifiers
    
    public func progressRing(progress: Double, thickness: CGFloat = 8, color: Color = DesignTokens.Colors.primary500) -> some View {
        self.overlay(
            CustomShapes.ProgressRing(progress: progress, thickness: thickness)
                .stroke(color, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
        )
    }
}

// MARK: - Custom Shape Components
public struct BrandedButton: View {
    private let title: String
    private let action: () -> Void
    private let style: ButtonStyle
    
    public enum ButtonStyle {
        case primary, secondary, tertiary
    }
    
    public init(_ title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.TextStyle.buttonText)
                .foregroundColor(textColor)
                .padding(.vertical, DesignTokens.Spacing.buttonPaddingVertical)
                .padding(.horizontal, DesignTokens.Spacing.buttonPaddingHorizontal)
                .frame(maxWidth: .infinity)
        }
        .deepSquircleBackground(backgroundColor)
        .deepSquircleBorder(lineWidth: borderWidth, color: borderColor)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return DesignTokens.Colors.primary500
        case .secondary: return DesignTokens.Colors.backgroundPrimary
        case .tertiary: return Color.clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: return DesignTokens.Colors.textInverse
        case .secondary: return DesignTokens.Colors.primary500
        case .tertiary: return DesignTokens.Colors.primary500
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return Color.clear
        case .secondary: return DesignTokens.Colors.primary500
        case .tertiary: return DesignTokens.Colors.primary500
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary: return 0
        case .secondary, .tertiary: return DesignTokens.BorderWidth.thin
        }
    }
}

public struct FinancialCard: View {
    private let content: AnyView
    private let shadowLevel: ShadowLevel
    
    public enum ShadowLevel {
        case none, light, medium, heavy
    }
    
    public init<Content: View>(shadowLevel: ShadowLevel = .medium, @ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
        self.shadowLevel = shadowLevel
    }
    
    public var body: some View {
        content
            .padding(DesignTokens.Spacing.cardPadding)
            // Fallback to an existing background token; previous token 'cardColor' is missing
            .cardBackground(DesignTokens.Colors.backgroundSecondary)
            .applyShadow(shadowLevel)
    }
}

// Provide a local helper to apply shadow levels using your design tokens.
private extension View {
    func applyShadow(_ level: FinancialCard.ShadowLevel) -> some View {
        switch level {
        case .none:
            return AnyView(self)
        case .light:
            return AnyView(self.shadowToken(DesignTokens.Shadow.sm))
        case .medium:
            return AnyView(self.shadowToken(DesignTokens.Shadow.md))
        case .heavy:
            return AnyView(self.shadowToken(DesignTokens.Shadow.lg))
        }
    }
}

public struct ProgressIndicator: View {
    private let progress: Double
    private let size: CGFloat
    private let thickness: CGFloat
    private let color: Color
    
    public init(progress: Double, size: CGFloat = 60, thickness: CGFloat = 6, color: Color = DesignTokens.Colors.primary500) {
        self.progress = progress
        self.size = size
        self.thickness = thickness
        self.color = color
    }
    
    public var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: thickness)
            
            // Progress ring
            CustomShapes.ProgressRing(progress: progress, thickness: thickness)
                .stroke(color, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
        .frame(width: size, height: size)
    }
}

#if DEBUG
// MARK: - Custom Shapes Preview
struct CustomShapes_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Shapes showcase
            ShapesShowcaseView()
                .previewDisplayName("Custom Shapes")
            
            // Brand components showcase
            BrandComponentsView()
                .previewDisplayName("Brand Components")
        }
    }
}

struct ShapesShowcaseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                
                // Brand Shapes
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Brand Shapes")
                        .font(.headline)
                    
                    HStack(spacing: DesignTokens.Spacing.md) {
                        // Deep Squircle
                        VStack {
                            CustomShapes.DeepSquircle()
                                .fill(DesignTokens.Colors.primary500)
                                .frame(width: 60, height: 60)
                            Text("Deep Squircle")
                                .font(.caption)
                        }
                        
                        // Card Shape
                        VStack {
                            CustomShapes.CardShape()
                                .fill(DesignTokens.Colors.secondary500)
                                .frame(width: 60, height: 40)
                            Text("Card")
                                .font(.caption)
                        }
                        
                        // Progress Ring
                        VStack {
                            CustomShapes.ProgressRing(progress: 0.7)
                                .stroke(DesignTokens.Colors.success, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 60, height: 60)
                            Text("Progress Ring")
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                }
                
                Divider()
                
                // Vector Icons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Vector Icons")
                        .font(.headline)
                    
                    HStack(spacing: DesignTokens.Spacing.md) {
                        VStack {
                            VectorIcons.MoneySymbol()
                                .stroke(DesignTokens.Colors.success, lineWidth: 2)
                                .frame(width: 60, height: 60)
                            Text("Money Symbol")
                                .font(.caption)
                        }
                        
                        VStack {
                            VectorIcons.WalletShape()
                                .fill(DesignTokens.Colors.tertiary500)
                                .frame(width: 60, height: 60)
                            Text("Wallet")
                                .font(.caption)
                        }
                        
                        VStack {
                            VectorIcons.ChartBar(values: [0.3, 0.7, 0.5, 0.9, 0.4])
                                .fill(DesignTokens.Colors.primary500)
                                .frame(width: 60, height: 60)
                            Text("Chart Bar")
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Custom Shapes")
    }
}

struct BrandComponentsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                
                // Branded Buttons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Branded Buttons")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    BrandedButton("Primary Button", style: .primary) {}
                    BrandedButton("Secondary Button", style: .secondary) {}
                    BrandedButton("Tertiary Button", style: .tertiary) {}
                }
                
                // Financial Cards
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Financial Cards")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    FinancialCard(shadowLevel: .medium) {
                        VStack(alignment: .leading) {
                            Text("Checking Account")
                                .font(.headline)
                            Text("$2,345.67")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignTokens.Colors.success)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Progress Indicators
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Progress Indicators")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: DesignTokens.Spacing.lg) {
                        ProgressIndicator(progress: 0.3, color: DesignTokens.Colors.warning)
                        ProgressIndicator(progress: 0.7, color: DesignTokens.Colors.primary500)
                        ProgressIndicator(progress: 0.9, color: DesignTokens.Colors.success)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Brand Components")
    }
}
#endif

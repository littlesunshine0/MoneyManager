import SwiftUI

// MARK: - Types

/// Elevation presets for AccountRowContainer
public enum AccountRowElevation: Equatable {
    case none
    case subtle       // very light
    case raised       // card-like
    case elevated     // prominent

    fileprivate var shadow: (colorOpacity: Double, radius: CGFloat, y: CGFloat) {
        switch self {
        case .none:      return (0, 0, 0)
        case .subtle:    return (0.10, 6, 2)
        case .raised:    return (0.14, 10, 4)
        case .elevated:  return (0.18, 18, 8)
        }
    }
}

/// Explicit appearance for the container (auto uses system ColorScheme)
public enum RowAppearance: Equatable {
    case auto
    case light
    case dark
}

// Programmatic design tokens for this container (no asset catalog usage)
public enum RowAccentTokens {
    /// Tailwind Indigo 500 (#6366F1) expressed in sRGB.
    static let selectionBase: Color = Color(.sRGB, red: 99.0/255.0, green: 102.0/255.0, blue: 241.0/255.0, opacity: 1.0)
}

/// A reusable row/card container that provides styling, elevation, and interaction
/// without dictating the inner layout. Suitable for use in lists and scroll views.
struct AccountRowContainer<Content: View>: View {
    // MARK: - Input

    let content: Content
    var action: (() -> Void)? = nil

    // Styling
    var cornerRadius: CGFloat
    var backgroundStyle: AnyShapeStyle
    var elevation: AccountRowElevation
    var showBorder: Bool
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    // Appearance
    var appearance: RowAppearance

    // Interaction
    var enableHover: Bool
    var enablePressFeedback: Bool

    // Selection/Loading
    var isSelected: Bool
    var selectionHighlightOpacity: Double
    var selectionShowsBorder: Bool
    var isLoading: Bool
    var showLoadingShimmer: Bool
    var selectionTint: Color? // Optional override for selection tint (defaults to .accentColor)

    // MARK: - State/Environment

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    #if os(macOS)
    @State private var isHovering = false
    #endif
    @State private var isPressed = false

    // MARK: - Init

    init(
        action: (() -> Void)? = nil,
        cornerRadius: CGFloat = 12,
        backgroundStyle: AnyShapeStyle = AnyShapeStyle(.thinMaterial),
        elevation: AccountRowElevation = .subtle,
        showBorder: Bool = false,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 12,
        appearance: RowAppearance = .auto,
        enableHover: Bool = true,
        enablePressFeedback: Bool = true,
        // New controls
        isSelected: Bool = false,
        selectionHighlightOpacity: Double = 0.12,
        selectionShowsBorder: Bool = true,
        isLoading: Bool = false,
        showLoadingShimmer: Bool = true,
        selectionTint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.action = action
        self.cornerRadius = cornerRadius
        self.backgroundStyle = backgroundStyle
        self.elevation = elevation
        self.showBorder = showBorder
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.appearance = appearance
        self.enableHover = enableHover
        self.enablePressFeedback = enablePressFeedback
        self.isSelected = isSelected
        self.selectionHighlightOpacity = selectionHighlightOpacity
        self.selectionShowsBorder = selectionShowsBorder
        self.isLoading = isLoading
        self.showLoadingShimmer = showLoadingShimmer
        self.selectionTint = selectionTint
    }

    // MARK: - Body

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Group {
            if let action {
                Button(action: action) {
                    containerBody(shape: shape)
                }
                .buttonStyle(.plain)
                .pressEvents(enabled: enablePressFeedback) { pressed in
                    withAppropriateAnimation { isPressed = pressed }
                }
            } else {
                containerBody(shape: shape)
                    .pressEvents(enabled: enablePressFeedback) { pressed in
                        withAppropriateAnimation { isPressed = pressed }
                    }
            }
        }
        .contentShape(shape)
        #if os(macOS)
        .onHover { hovering in
            guard enableHover else { return }
            withAppropriateAnimation { isHovering = hovering }
        }
        #endif
        .accessibilityAddTraits(action == nil ? [] : .isButton)
    }

    // MARK: - Icon Palette (adaptive, non-clashing for light/dark & selection)
    private var iconBackgroundColor: Color {
        if isSelected {
            return selectionBaseColor.opacity(effectiveScheme == .dark ? 0.26 : 0.20)
        } else {
            return effectiveScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.06)
        }
    }
    private var iconForegroundColor: Color {
        if isSelected {
            return Color.white
        } else {
            return effectiveScheme == .dark ? Color.white.opacity(0.92) : Color.black.opacity(0.85)
        }
    }

    // MARK: - Building Blocks

    @ViewBuilder
    private func containerBody(shape: RoundedRectangle) -> some View {
        let baseContent = content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)

        let contentWithLoading = baseContent
            .modifier(LoadingRedactionModifier(isLoading: isLoading))
            .overlay {
                if isLoading && showLoadingShimmer {
                    ShimmerView()
                        .clipShape(shape)
                        .allowsHitTesting(false)
                }
            }

        contentWithLoading
            .environment(\.rowIconBackground, iconBackgroundColor)
            .environment(\.rowIconForeground, iconForegroundColor)
            // Background: always render the base surface
            .background(
                resolvedBackgroundStyle,
                in: shape
            )
            // Selection overlay: tint on top of the surface so it works on light/dark surfaces
            .overlay {
                if isSelected {
                    shape
                        .fill(selectedBackgroundStyle)
                        .blendMode(effectiveScheme == .dark ? .plusLighter : .overlay)
                        .allowsHitTesting(false)
                }
            }
            // Border(s) — gradient that subtly transitions with shadow/interaction
            .overlay {
                if showBorder || (isSelected && selectionShowsBorder) {
                    shape
                        .stroke(borderGradient, lineWidth: borderLineWidth)
                        .allowsHitTesting(false)
                }
            }
            // Elevation + interaction-driven lift (boost when selected)
            .shadow(color: shadowColor.opacity(effectiveShadowOpacity),
                    radius: effectiveShadow.radius + (isSelected ? 2 : 0),
                    x: 0, y: effectiveShadow.y)
            // Optional subtle outer selection glow for clarity
            .shadow(color: isSelected ? selectionBaseColor.opacity(effectiveScheme == .dark ? 0.22 : 0.16) : .clear,
                    radius: isSelected ? 6 : 0, x: 0, y: 0)
            // Subtle press/hover feedback
            .scaleEffect(effectiveScale)
            .opacity(effectiveOpacity)
            .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.92), value: isPressed)
            #if os(macOS)
            .animation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.95), value: isHovering)
            #endif
    }

    private var resolvedBackgroundStyle: AnyShapeStyle {
        if reduceTransparency {
            // Fall back to a subtle color for platforms that support materials
            let base = effectiveScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.04)
            return AnyShapeStyle(base)
        } else {
            return backgroundStyle
        }
    }

    // Selected background fully replaces the normal background when selected
    private var selectedBackgroundStyle: AnyShapeStyle {
        let base = selectionBaseColor
        // Slight vertical gradient using the selection tint for depth
        let topOpacity: Double = {
            // Ensure it's clearly different from base background and readable
            let minLight = max(selectionHighlightOpacity, 0.18)
            let minDark  = max(selectionHighlightOpacity, 0.22)
            return effectiveScheme == .dark ? minDark : minLight
        }()
        let bottomOpacity: Double = topOpacity + (effectiveScheme == .dark ? 0.06 : 0.04)

        let gradient = LinearGradient(
            gradient: Gradient(colors: [
                base.opacity(topOpacity),
                base.opacity(bottomOpacity)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        return AnyShapeStyle(gradient)
    }

    // MARK: Border styling (adaptive gradient)

    private var borderLineWidth: CGFloat {
        isSelected ? 1.25 : 1.0
    }

    private var borderGradient: LinearGradient {
        let boost = borderContrastBoost
        if isSelected {
            // Accent-tinted border when selected (programmatic color)
            let top = selectionBaseColor.opacity(min(1.0, 0.85 + boost * 0.5))
            let bottom = selectionBaseColor.opacity(min(1.0, 0.55 + boost * 0.3))
            return LinearGradient(
                colors: [top, bottom],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            // Neutral border when not selected
            let darkGrayBase = effectiveScheme == .dark ? Color.white.opacity(0.28) : Color.black.opacity(0.28)
            let lightGrayBase = effectiveScheme == .dark ? Color.white.opacity(0.16) : Color.black.opacity(0.16)
            let top = darkGrayBase.opacity(min(1.0, 1.0 + boost * 0.6))
            let bottom = lightGrayBase.opacity(min(1.0, 1.0 + boost * 0.3))
            return LinearGradient(
                colors: [top, bottom],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var borderContrastBoost: Double {
        var boost: Double = 0
        #if os(macOS)
        if enableHover && isHovering { boost += 0.35 }
        #endif
        if enablePressFeedback && isPressed { boost += 0.45 }
        if isSelected { boost += 0.35 }
        // Gentle cap
        return min(boost, 0.8)
    }

    private var selectionBaseColor: Color {
        selectionTint ?? RowAccentTokens.selectionBase
    }

    private var selectionHighlightColor: Color {
        // Kept for compatibility; now used only for outer glow computation
        let base = selectionBaseColor
        let adaptiveOpacity = effectiveScheme == .dark
            ? max(selectionHighlightOpacity, 0.18)
            : max(selectionHighlightOpacity, 0.14)
        return base.opacity(adaptiveOpacity)
    }

    private var effectiveScheme: ColorScheme {
        switch appearance {
        case .auto: return colorScheme
        case .light: return .light
        case .dark: return .dark
        }
    }

    private var shadowColor: Color {
        Color.black
    }

    private var effectiveShadow: (radius: CGFloat, y: CGFloat) {
        let base = elevation.shadow
        // Lift on press/hover
        #if os(macOS)
        let interactionBoost = (enableHover && isHovering) || (enablePressFeedback && isPressed)
        #else
        let interactionBoost = enablePressFeedback && isPressed
        #endif

        if interactionBoost {
            return (radius: base.radius + 4, y: max(0, base.y - 2))
        } else {
            return (radius: base.radius, y: base.y)
        }
    }

    private var effectiveShadowOpacity: Double {
        var base = elevation.shadow.colorOpacity
        #if os(macOS)
        if enableHover && isHovering { base += 0.04 }
        #endif
        if enablePressFeedback && isPressed { base += 0.06 }
        if isSelected { base += 0.04 }
        return min(base, 0.30)
    }

    private var effectiveScale: CGFloat {
        guard enablePressFeedback || (isHoveringEnabled && isHoveringSupported) else { return 1.0 }
        #if os(macOS)
        if enableHover && isHovering { return 1.01 }
        #endif
        if enablePressFeedback && isPressed { return 0.985 }
        return 1.0
    }

    private var effectiveOpacity: Double {
        if enablePressFeedback && isPressed { return 0.98 }
        return 1.0
    }

    private var isHoveringEnabled: Bool {
        #if os(macOS)
        return enableHover
        #else
        return false
        #endif
    }

    private var isHoveringSupported: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    private func withAppropriateAnimation(_ changes: () -> Void) {
        if reduceMotion {
            changes()
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.92), changes)
        }
    }
}

// MARK: - Small helpers

private struct RowIconBackgroundKey: EnvironmentKey { static let defaultValue: Color = .clear }
private struct RowIconForegroundKey: EnvironmentKey { static let defaultValue: Color = .primary }
private extension EnvironmentValues {
    var rowIconBackground: Color {
        get { self[RowIconBackgroundKey.self] }
        set { self[RowIconBackgroundKey.self] = newValue }
    }
    var rowIconForeground: Color {
        get { self[RowIconForegroundKey.self] }
        set { self[RowIconForegroundKey.self] = newValue }
    }
}

private extension View {
    // A tiny utility to detect press state without altering ButtonStyle layout.
    func pressEvents(enabled: Bool, onChange: @escaping (Bool) -> Void) -> some View {
        modifier(PressEventsModifier(enabled: enabled, onChange: onChange))
    }
}

private struct PressEventsModifier: ViewModifier {
    let enabled: Bool
    let onChange: (Bool) -> Void

    func body(content: Content) -> some View {
        if enabled {
            content
                .onLongPressGesture(minimumDuration: 0.001, maximumDistance: 24, pressing: { isPressing in
                    onChange(isPressing)
                }, perform: {})
        } else {
            content
        }
    }
}

// MARK: - Loading helpers

private struct LoadingRedactionModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        if isLoading {
            // Keep taps enabled so the row remains selectable while showing placeholders.
            content
                .redacted(reason: .placeholder)
        } else {
            content
        }
    }
}

private struct ShimmerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1.0

    var body: some View {
        GeometryReader { proxy in
            let gradient = LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white.opacity(0.10), location: 0.0),
                    .init(color: Color.white.opacity(0.35), location: 0.5),
                    .init(color: Color.white.opacity(0.10), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Rectangle()
                .fill(gradient)
                .rotationEffect(.degrees(15))
                .offset(x: phase * proxy.size.width * 1.5)
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1.0
                    }
                }
        }
        .compositingGroup()
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }
}

// MARK: - Background presets

extension AnyShapeStyle {
    static var rowGlass: AnyShapeStyle { AnyShapeStyle(.ultraThinMaterial) }
    static var rowTintedGlass: AnyShapeStyle { AnyShapeStyle(.thinMaterial) }
    static func rowTint(_ color: Color, opacity: Double = 0.08) -> AnyShapeStyle {
        AnyShapeStyle(color.opacity(opacity))
    }
    // New: lighter blue → indigo gradient preset
    static var rowBlueIndigoGradient: AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.10),
                    Color.indigo.opacity(0.16)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    static var rowLightSurface: AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.95),
                    Color(.sRGB, red: 0.98, green: 0.99, blue: 1.0, opacity: 0.92)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    static var rowDarkSurface: AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 0.10, green: 0.11, blue: 0.16, opacity: 0.70),
                    Color(.sRGB, red: 0.07, green: 0.08, blue: 0.12, opacity: 0.78)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
#if DEBUG
struct RowIconBubble: View {
    let systemName: String
    var size: CGFloat = 36
    var cornerRadius: CGFloat = 8
    @Environment(\.rowIconBackground) private var iconBg
    @Environment(\.rowIconForeground) private var iconFg
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(iconBg)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundStyle(iconFg)
            )
    }
}

// Rainbow icon that adapts well to both light/dark
struct RainbowIconBubble: View {
    let systemName: String
    let index: Int
    var size: CGFloat = 36
    var cornerRadius: CGFloat = 8
    @Environment(\.colorScheme) private var scheme

    private let palette: [Color] = [
        .red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink
    ]

    private var base: Color {
        palette[index % palette.count]
    }

    private var bg: Color {
        // Slightly stronger in dark for contrast against darker surfaces
        scheme == .dark ? base.opacity(0.28) : base.opacity(0.18)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(bg)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundStyle(.white)
            )
    }
}

extension AccountRowContainer {
    static func light(
        action: (() -> Void)? = nil,
        cornerRadius: CGFloat = 12,
        backgroundStyle: AnyShapeStyle = .rowLightSurface,
        elevation: AccountRowElevation = .subtle,
        showBorder: Bool = true,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 12,
        enableHover: Bool = true,
        enablePressFeedback: Bool = true,
        isSelected: Bool = false,
        selectionHighlightOpacity: Double = 0.12,
        selectionShowsBorder: Bool = true,
        isLoading: Bool = false,
        showLoadingShimmer: Bool = true,
        selectionTint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) -> AccountRowContainer<Content> {
        AccountRowContainer(
            action: action,
            cornerRadius: cornerRadius,
            backgroundStyle: backgroundStyle,
            elevation: elevation,
            showBorder: showBorder,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            appearance: .light,
            enableHover: enableHover,
            enablePressFeedback: enablePressFeedback,
            isSelected: isSelected,
            selectionHighlightOpacity: selectionHighlightOpacity,
            selectionShowsBorder: selectionShowsBorder,
            isLoading: isLoading,
            showLoadingShimmer: showLoadingShimmer,
            selectionTint: selectionTint,
            content: content
        )
    }
    static func dark(
        action: (() -> Void)? = nil,
        cornerRadius: CGFloat = 12,
        backgroundStyle: AnyShapeStyle = .rowDarkSurface,
        elevation: AccountRowElevation = .subtle,
        showBorder: Bool = true,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 12,
        enableHover: Bool = true,
        enablePressFeedback: Bool = true,
        isSelected: Bool = false,
        selectionHighlightOpacity: Double = 0.12,
        selectionShowsBorder: Bool = true,
        isLoading: Bool = false,
        showLoadingShimmer: Bool = true,
        selectionTint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) -> AccountRowContainer<Content> {
        AccountRowContainer(
            action: action,
            cornerRadius: cornerRadius,
            backgroundStyle: backgroundStyle,
            elevation: elevation,
            showBorder: showBorder,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            appearance: .dark,
            enableHover: enableHover,
            enablePressFeedback: enablePressFeedback,
            isSelected: isSelected,
            selectionHighlightOpacity: selectionHighlightOpacity,
            selectionShowsBorder: selectionShowsBorder,
            isLoading: isLoading,
            showLoadingShimmer: showLoadingShimmer,
            selectionTint: selectionTint,
            content: content
        )
    }
}

// MARK: - Previews

// Interactive selection preview so any tapped row highlights.
private struct InteractiveSelectionPreview: View {
    @State private var selectedIndex: Int? = 2
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<12, id: \.self) { idx in
                    AccountRowContainer(
                        action: { withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) { selectedIndex = idx } },
                        cornerRadius: 12,
                        backgroundStyle: .rowBlueIndigoGradient,
                        elevation: .raised,
                        showBorder: true,
                        horizontalPadding: 16,
                        verticalPadding: 14,
                        enableHover: true,
                        enablePressFeedback: true,
                        isSelected: selectedIndex == idx,
                        selectionHighlightOpacity: 0.16,
                        selectionShowsBorder: true,
                        isLoading: isLoading && idx < 3, // show loading on first few rows if toggled
                        showLoadingShimmer: true,
                        selectionTint: RowAccentTokens.selectionBase
                    ) {
                        HStack {
                            RainbowIconBubble(systemName: iconName(for: idx), index: idx)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Account \(idx + 1)")
                                    .font(.headline)
                                Text("Ending in ••••\(1234 + idx)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(Int.random(in: 100...999)).\(Int.random(in: 10...99))")
                                    .font(.headline)
                                Text("Updated just now")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 64)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
        }
        .tint(RowAccentTokens.selectionBase)
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(isLoading ? "Stop Loading" : "Simulate Loading") {
                    withAnimation(.easeInOut(duration: 0.25)) { isLoading.toggle() }
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.08),
                    Color.indigo.opacity(0.10),
                    Color.clear
                ]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private func iconName(for idx: Int) -> String {
        // Rotate a few SF Symbols for variety
        let symbols = ["creditcard.fill", "building.columns.fill", "banknote.fill", "dollarsign.circle.fill", "chart.bar.fill", "wallet.pass.fill"]
        return symbols[idx % symbols.count]
    }
}

#Preview("AccountRowContainer – Interactive Selection") {
    InteractiveSelectionPreview()
}

#Preview("AccountRowContainer – Light Surface") {
    ScrollView {
        LazyVStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { idx in
                AccountRowContainer.light(
                    showBorder: true,
                    isSelected: idx == 1,
                    selectionTint: RowAccentTokens.selectionBase
                ) {
                    HStack {
                        RainbowIconBubble(systemName: "building.columns.fill", index: idx)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Checking ••••\(1200 + idx)").font(.headline)
                            Text("Updated today").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("$\(Int.random(in: 1000...6200)).\(Int.random(in: 10...99))").font(.headline)
                    }
                    .frame(height: 64)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
    }
    #if canImport(UIKit)
    .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    #elseif canImport(AppKit)
    .background(Color(NSColor.windowBackgroundColor).ignoresSafeArea())
    #else
    .background(Color.gray.opacity(0.1).ignoresSafeArea())
    #endif
    .preferredColorScheme(.light)
}

private struct DarkSurfacePreview: View {
    @State private var selectedIndex: Int? = 2
    @State private var isLoading = false

    var body: some View {
        PreviewDockHost {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { idx in
                        AccountRowContainer.dark(
                            action: { withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) { selectedIndex = idx } },
                            showBorder: true,
                            isSelected: selectedIndex == idx,
                            selectionHighlightOpacity: 0.16,
                            isLoading: isLoading && idx < 3,
                            showLoadingShimmer: true,
                            selectionTint: RowAccentTokens.selectionBase
                        ) {
                            HStack {
                                RainbowIconBubble(systemName: "creditcard.fill", index: idx)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Card \(idx + 1)").font(.headline)
                                    Text("Updated 2h ago").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("$\(Int.random(in: 200...1900)).\(Int.random(in: 10...99))").font(.headline)
                            }
                            .frame(height: 64)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
            }
            .tint(RowAccentTokens.selectionBase)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(isLoading ? "Stop Loading" : "Simulate Loading") {
                        withAnimation(.easeInOut(duration: 0.25)) { isLoading.toggle() }
                    }
                }
            }
        }
        .background(Color.black.opacity(0.92).ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview("AccountRowContainer – Dark Surface") {
    DarkSurfacePreview()
}
#endif

// Minimal item model for the dock
private struct DockHomeItem: Identifiable {
    let id = UUID()
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void
}

// Minimal dock view for previews
private struct DockHomeView: View {
    let items: [DockHomeItem]
    let selectedIndex: Int?
    let onSelect: (Int) -> Void

    private struct DockItemLabel: View {
        let systemName: String
        let isSelected: Bool

        var body: some View {
            VStack(spacing: 6) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))

                Circle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 6, height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                Button {
                    onSelect(index)
                    item.action()
                } label: {
                    DockItemLabel(systemName: item.systemName, isSelected: selectedIndex == index)
                        .accessibilityLabel(item.accessibilityLabel)
                        .accessibilityAddTraits(selectedIndex == index ? .isSelected : [])
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Shared dock items for “Accounts Home”
private struct PreviewDockHost<Content: View>: View {
    @State private var selectedDockIndex: Int? = 0
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private var dockItems: [DockHomeItem] {
        [
            DockHomeItem(systemName: "house.fill", accessibilityLabel: "Home") {},
            DockHomeItem(systemName: "wallet.pass.fill", accessibilityLabel: "Accounts") {},
            DockHomeItem(systemName: "chart.pie.fill", accessibilityLabel: "Analytics") {},
            DockHomeItem(systemName: "plus.app.fill", accessibilityLabel: "Add") {},
            DockHomeItem(systemName: "person.fill", accessibilityLabel: "Profile") {}
        ]
    }

    var body: some View {
        content
            .padding(.bottom, 96)
            .safeAreaInset(edge: .bottom) {
                DockHomeView(
                    items: dockItems,
                    selectedIndex: selectedDockIndex,
                    onSelect: { idx in selectedDockIndex = idx }
                )
 //               .tint(PreviewTokens.accent)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.primary.opacity(0.10))
                        .frame(height: 0.5),
                    alignment: .top
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
    }
}
import SwiftUI

// MARK: - Dock Item Model
public struct DockItem: Identifiable {
    public let id = UUID()
    let systemName: String
    let accessibilityLabel: String?
    let action: () -> Void

    public init(systemName: String, accessibilityLabel: String? = nil, action: @escaping () -> Void) {
        self.systemName = systemName
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
}

// MARK: - Reusable Dock View (supports non-scrollable or scrollable content + selection highlight)
struct DockView: View {
    var items: [DockItem]
    var iconSize: CGFloat = 22
    var horizontalPadding: CGFloat = 18
    var verticalPadding: CGFloat = 12
    var itemSpacing: CGFloat = 18
    var scrollable: Bool = false        // prevent expansion when false
    var showsEdgeFades: Bool = true

    // Selection
    var selectedIndex: Int?
    var onSelect: (Int) -> Void

    @Environment(\.colorScheme) private var scheme
    @Namespace private var selectionNamespace

    var body: some View {
        let row = Group {
            if scrollable {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: itemSpacing) {
                        dockButtons
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                }
            } else {
                HStack(spacing: itemSpacing) {
                    dockButtons
                }
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .fixedSize(horizontal: true, vertical: false)
            }
        }

        return ZStack {
            row
                .background(.thinMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(scheme == .dark ? 0.18 : 0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(scheme == .dark ? 0.24 : 0.18), radius: 10, x: 0, y: 6)
                .overlay {
                    if scrollable && showsEdgeFades {
                        HStack {
                            LinearGradient(
                                colors: [
                                    (scheme == .dark ? Color.black : Color.white).opacity(0.25),
                                    .clear
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .frame(width: 18)
                            Spacer(minLength: 0)
                            LinearGradient(
                                colors: [
                                    .clear,
                                    (scheme == .dark ? Color.black : Color.white).opacity(0.25)
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .frame(width: 18)
                        }
                        .allowsHitTesting(false)
                        .clipShape(Capsule())
                    }
                }
        }
    }

    // Gradient used to highlight the selected dock item
    private var selectionGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.cyan.opacity(0.55),
                Color.blue.opacity(0.52),
                Color.indigo.opacity(0.50)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    @ViewBuilder
    private var dockButtons: some View {
        ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
            Button {
                onSelect(index)
                item.action()
            } label: {
                ZStack {
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selectionGradient)
                            .matchedGeometryEffect(id: "dockSelection", in: selectionNamespace)
                            .frame(width: max(iconSize + 10, 32) + 16, height: max(iconSize + 10, 32) + 8)
                            .shadow(color: Color.cyan.opacity(0.22), radius: 10, x: 0, y: 4)
                            .transition(.opacity.combined(with: .scale))
                    }

                    Image(systemName: item.systemName)
                        .font(.system(size: iconSize, weight: .semibold))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(selectedIndex == index ? .white : .primary)
                        .frame(width: max(iconSize + 10, 32), height: max(iconSize + 10, 32))
                }
                .contentShape(Rectangle())
                .animation(.spring(response: 0.32, dampingFraction: 0.85), value: selectedIndex)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.accessibilityLabel ?? item.systemName)
        }
    }
}

// MARK: - Floating Search Button (circular, trailing)
struct FloatingSearchButton: View {
    var size: CGFloat = 56
    var action: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.28),
                                        Color.white.opacity(0.16)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(scheme == .dark ? 0.30 : 0.25), radius: 14, x: 0, y: 10)
                    .shadow(color: Color.cyan.opacity(0.16), radius: 18, x: 0, y: 8)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Search")
        .accessibilityHint("Open search")
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedDockIndex: Int? = 0

    // Exactly 5 dock items as requested
    private var dockItems: [DockItem] {
        [
            DockItem(systemName: "house.fill", accessibilityLabel: "Home") { print("Home tapped") },
            DockItem(systemName: "wallet.pass.fill", accessibilityLabel: "Accounts") { print("Accounts tapped") },
            DockItem(systemName: "chart.pie.fill", accessibilityLabel: "Analytics") { print("Analytics tapped") },
            DockItem(systemName: "plus.app.fill", accessibilityLabel: "Add") { print("Add tapped") },
            DockItem(systemName: "person.fill", accessibilityLabel: "Profile") { print("Profile tapped") }
        ]
    }

    var body: some View {
        ZStack {
            // Your main app content goes here
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 1. A VStack to arrange content with the dock at the bottom.
            VStack(spacing: 15) {
                // 2. Spacer pushes the content below it to the bottom.
                Spacer()

                // 3. Bottom bar: left dock (content-sized) + trailing floating search button
                HStack(alignment: .center) {
                    DockView(
                        items: dockItems,
                        iconSize: 22,
                        horizontalPadding: 18,
                        verticalPadding: 12,
                        itemSpacing: 18,
                        scrollable: false,
                        showsEdgeFades: false,
                        selectedIndex: selectedDockIndex,
                        onSelect: { idx in
                            selectedDockIndex = idx
                        }
                    )
                    .padding(.leading, 8)

                    Spacer(minLength: 12)

                    FloatingSearchButton {
                        // TODO: present search UI or toggle a search overlay
                        print("Search button tapped")
                    }
                    .padding(.trailing, 8)
                    .zIndex(2) // ensure it stays above any dock visuals
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

struct ContentView_iPad_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewDisplayName("iPad")
    }
}
struct ContentView_Mac_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1024, height: 768)
            .previewDisplayName("Mac")
    }
}
struct ContentView_TV_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("Apple TV 4K (3rd generation)")
            .previewDisplayName("Apple TV")
    }
}

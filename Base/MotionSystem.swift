import SwiftUI

// MARK: - Motion System
public struct MotionSystem {
    
    // MARK: - Motion Tokens (Duration, Easing, Timing)
    public struct Duration {
        public static let instant: Double = 0.0
        public static let immediate: Double = 0.1
        public static let quick: Double = 0.2
        public static let normal: Double = 0.3
        public static let comfortable: Double = 0.5
        public static let relaxed: Double = 0.8
        public static let slow: Double = 1.2
        public static let extra: Double = 2.0
    }
    
    public struct Easing {
        // Standard easing curves
        public static let linear = Animation.linear
        public static let easeIn = Animation.easeIn
        public static let easeOut = Animation.easeOut
        public static let easeInOut = Animation.easeInOut
        
        // Custom financial app easing (feels premium)
        public static let smooth = Animation.timingCurve(0.4, 0.0, 0.2, 1.0)
        public static let bounce = Animation.interpolatingSpring(stiffness: 300, damping: 20)
        public static let gentle = Animation.timingCurve(0.25, 0.46, 0.45, 0.94)
        public static let snappy = Animation.timingCurve(0.68, -0.55, 0.265, 1.55)
    }
    
    // MARK: - Spring Tokens (Physics-based presets)
    public struct Spring {
        // Response/damping-based springs (feel more natural for UI)
        public static let subtle = Animation.spring(response: 0.28, dampingFraction: 0.85, blendDuration: 0.0)
        public static let smooth = Animation.spring(response: 0.36, dampingFraction: 0.82, blendDuration: 0.0)
        public static let lively = Animation.spring(response: 0.28, dampingFraction: 0.72, blendDuration: 0.0)
        public static let snappy = Animation.spring(response: 0.22, dampingFraction: 0.68, blendDuration: 0.0)
        
        // Stiffness/damping-based springs (for precise control)
        public static let stiff = Animation.interpolatingSpring(stiffness: 300, damping: 24)
        public static let bouncy = Animation.interpolatingSpring(stiffness: 220, damping: 16)
        public static let heavy = Animation.interpolatingSpring(stiffness: 500, damping: 36)
    }
    
    public struct Delay {
        public static let none: Double = 0.0
        public static let short: Double = 0.1
        public static let medium: Double = 0.2
        public static let long: Double = 0.3
        public static let extra: Double = 0.5
    }
    
    // MARK: - Particle Defaults
    public struct Particles {
        public static let defaultCount: Int = 28
        public static let defaultLifetime: ClosedRange<TimeInterval> = 0.9...1.6
        public static let defaultSize: ClosedRange<CGFloat> = 4...7
        public static let defaultJitterAmplitude: CGFloat = 14
    }
    
    // MARK: - Stagger Utilities
    public enum StaggerCurve {
        case linear
        case easeInCluster
        case easeOutCluster
        case symmetric
    }
    
    /// Compute a staggered delay for an item at index within count.
    /// Returns 0 when reduce motion is enabled.
    public static func staggeredDelay(
        index: Int,
        count: Int,
        base: Double = Delay.short,
        curve: StaggerCurve = .linear,
        reduceMotion: Bool = false
    ) -> Double {
        guard !reduceMotion, count > 1, index >= 0 else { return 0 }
        let t = Double(index) / Double(max(count - 1, 1)) // 0...1
        switch curve {
        case .linear:
            return base * t
        case .easeInCluster:
            // cluster more at the start
            return base * pow(t, 0.6)
        case .easeOutCluster:
            // cluster more at the end
            return base * pow(t, 1.8)
        case .symmetric:
            // meet in the middle
            let d = abs(t - 0.5) * 2
            return base * (1 - d)
        }
    }
    
    // MARK: - Global Motion Scaling (Environment-driven)
    // Useful for demos, QA, or power users who like slower/faster motion.
    public static var defaultSpeedScale: Double = 1.0
    public static var defaultDelayScale: Double = 1.0
    
    // MARK: - Centralized animation builder
    // Applies duration/easing/delay and respects Reduce Motion when requested.
    public static func animation(
        duration: Double,
        easing: Animation = MotionSystem.Easing.smooth,
        delay: Double = 0.0,
        respectReduceMotion: Bool = true,
        reduceMotion: Bool? = nil,
        speedScale: Double? = nil,
        delayScale: Double? = nil
    ) -> Animation {
        let reduce: Bool
        #if canImport(UIKit)
        // UIKit-backed platforms (iOS, iPadOS, tvOS)
        reduce = reduceMotion ?? UIAccessibility.isReduceMotionEnabled
        #else
        // Other platforms fallback (macOS, watchOS, visionOS)
        reduce = reduceMotion ?? false
        #endif
        
        let globalSpeed = speedScale ?? MotionSystem.defaultSpeedScale
        let globalDelay = delayScale ?? MotionSystem.defaultDelayScale
        
        if respectReduceMotion && reduce {
            return .default // effectively no animated movement in our modifiers
        } else {
            // Approximate requested duration by scaling animation speed
            let base = MotionSystem.Duration.normal
            let clamped = max(duration, 0.0001)
            let speedFactor = (base / clamped) * max(0.001, globalSpeed)
            return easing
                .delay(delay * globalDelay)
                .speed(speedFactor)
        }
    }
}

// MARK: - Environment Keys for Motion Scaling
private struct MotionSpeedScaleKey: EnvironmentKey {
    static let defaultValue: Double = MotionSystem.defaultSpeedScale
}
private struct MotionDelayScaleKey: EnvironmentKey {
    static let defaultValue: Double = MotionSystem.defaultDelayScale
}

public extension EnvironmentValues {
    var motionSpeedScale: Double {
        get { self[MotionSpeedScaleKey.self] }
        set { self[MotionSpeedScaleKey.self] = newValue }
    }
    var motionDelayScale: Double {
        get { self[MotionDelayScaleKey.self] }
        set { self[MotionDelayScaleKey.self] = newValue }
    }
}

public extension View {
    func motionSpeedScale(_ scale: Double) -> some View {
        environment(\.motionSpeedScale, max(0.001, scale))
    }
    func motionDelayScale(_ scale: Double) -> some View {
        environment(\.motionDelayScale, max(0.0, scale))
    }
}

// MARK: - Branded Animation Types
public enum BrandedAnimationType {
    // Characters
    case welcomeCharacter
    case successCharacter
    case thinkingCharacter
    case celebrationCharacter
    
    // Animals (Financial metaphors)
    case piggyBank          // Savings
    case bull              // Investment growth
    case bear              // Market decline
    case owl               // Wise spending
    case rabbit            // Quick transactions
    
    // Platform Elements
    case moneyFlow         // Money flowing between accounts
    case stackingCoins     // Building wealth
    case chartGrowth       // Portfolio growth
    case goalProgress      // Reaching financial goals
    
    // Permission-related
    case biometricScan     // Face ID / Touch ID
    case cameraPermission  // Receipt scanning
    case locationPermission // Transaction locations
    case notificationPermission // Budget alerts
}

// MARK: - Motion Components

// MoneyFlow particle model
private struct MoneyParticle: Hashable, Identifiable {
    let id = UUID()
    let seed: UInt64
    let birth: TimeInterval
    let lifetime: TimeInterval
    let start: CGPoint
    let end: CGPoint
    let speed: CGFloat
    let perpendicularJitter: CGFloat
    let size: CGFloat
    
    func progress(at time: TimeInterval) -> CGFloat {
        let age = time - birth
        guard lifetime > 0 else { return 1 }
        // Wrap progress into 0...1 so we never need to mutate state to respawn
        let wrapped = age.truncatingRemainder(dividingBy: lifetime)
        return CGFloat(min(max(wrapped / lifetime, 0), 1))
    }
}

// Random helpers (stable per-seed)
private extension UInt64 {
    mutating func nextNormalized() -> CGFloat {
        // Xorshift64* for deterministic randomness
        var x = self
        x &+= 0x9E3779B97F4A7C15
        var z = x
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        let final = z ^ (z >> 31)
        self = final
        // Map to 0...1
        let maxU = Double(UInt64.max)
        return CGFloat(Double(final & 0xFFFFFFFFFFFF) / maxU)
    }
}

/// Animated Money Flow - Canvas particles with lifetimes and jitter
public struct MoneyFlowAnimation: View {
    @State private var startTime: TimeInterval = 0
    @State private var particles: [MoneyParticle] = []
    @State private var labelProgress: CGFloat = 0.0
    
    private let fromPoint: CGPoint
    private let toPoint: CGPoint
    private let amount: Double
    private let duration: Double
    private let particleCount: Int
    private let particleLifetime: ClosedRange<TimeInterval>
    private let particleSize: ClosedRange<CGFloat>
    private let jitterAmplitude: CGFloat
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        from: CGPoint,
        to: CGPoint,
        amount: Double,
        duration: Double = MotionSystem.Duration.comfortable,
        particleCount: Int = MotionSystem.Particles.defaultCount,
        particleLifetime: ClosedRange<TimeInterval> = MotionSystem.Particles.defaultLifetime,
        particleSize: ClosedRange<CGFloat> = MotionSystem.Particles.defaultSize,
        jitterAmplitude: CGFloat = MotionSystem.Particles.defaultJitterAmplitude
    ) {
        self.fromPoint = from
        self.toPoint = to
        self.amount = amount
        self.duration = duration
        self.particleCount = particleCount
        self.particleLifetime = particleLifetime
        self.particleSize = particleSize
        self.jitterAmplitude = jitterAmplitude
    }
    
    public var body: some View {
        ZStack {
            if reduceMotion == false {
                TimelineView(.animation) { context in
                    let now = context.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in
                        // Initialize start time and seed particles (pure draw)
                        if startTime == 0 { startTime = now }
                        if particles.isEmpty {
                            particles = seedParticles(at: now)
                        }
                        
                        // Draw each particle with wrapped lifetime (no state mutation here)
                        for p in particles {
                            let t = p.progress(at: now)
                            
                            let pathPoint = pointAlongPath(from: p.start, to: p.end, progress: t)
                            let jittered = jitter(point: pathPoint, seed: p.seed, progress: t, amplitude: p.perpendicularJitter)
                            
                            // Fade in/out and scale over life
                            let fade = sin(Double(t) * .pi)
                            let opacity = max(0, min(1, fade)) * 0.95
                            let scale = 0.6 + 0.6 * CGFloat(fade)
                            let sizePx = p.size * scale
                            
                            var circle = Path(ellipseIn: CGRect(x: -sizePx/2, y: -sizePx/2, width: sizePx, height: sizePx))
                            let transform = CGAffineTransform(translationX: jittered.x + size.width/2,
                                                              y: jittered.y + size.height/2)
                            ctx.opacity = opacity
                            ctx.fill(circle.applying(transform), with: .color(DesignTokens.Colors.success))
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
            
            // Amount label that follows the path
            Text("$\(String(format: "%.2f", amount))")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(DesignTokens.Colors.success)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .offset(x: interpolate(from: fromPoint.x, to: toPoint.x, progress: labelProgress),
                        y: interpolate(from: fromPoint.y, to: toPoint.y, progress: labelProgress) - 20)
                .opacity(reduceMotion ? 1.0 : (labelProgress > 0.1 && labelProgress < 0.95 ? 1.0 : 0.0))
        }
        .onAppear {
            startLabelAnimation()
            if reduceMotion {
                // Static fallback: place label at endpoint (clearer than midpoint for directionality)
                labelProgress = 1.0
            }
        }
    }
    
    private func startLabelAnimation() {
        if reduceMotion || duration == 0 {
            labelProgress = 1.0
        } else {
            withAnimation(.easeInOut(duration: duration)) {
                labelProgress = 1.0
            }
        }
    }
    
    private func seedParticles(at now: TimeInterval) -> [MoneyParticle] {
        var seeded: [MoneyParticle] = []
        for i in 0..<particleCount {
            var seed = UInt64(i &+ 1) &* 0x9E3779B97F4A7C15
            let life = TimeInterval(seed.nextNormalized()) * (particleLifetime.upperBound - particleLifetime.lowerBound) + particleLifetime.lowerBound
            let size = seed.nextNormalized() * (particleSize.upperBound - particleSize.lowerBound) + particleSize.lowerBound
            let speed = CGFloat(0.85 + 0.3 * seed.nextNormalized())
            let jitter = jitterAmplitude * (0.5 + 0.8 * seed.nextNormalized())
            // Stagger starts by shifting birth backward
            let birth = now - TimeInterval(seed.nextNormalized()) * life
            let p = MoneyParticle(
                seed: seed,
                birth: birth,
                lifetime: life,
                start: fromPoint,
                end: toPoint,
                speed: speed,
                perpendicularJitter: jitter,
                size: size
            )
            seeded.append(p)
        }
        return seeded
    }
    
    private func pointAlongPath(from: CGPoint, to: CGPoint, progress t: CGFloat) -> CGPoint {
        CGPoint(x: interpolate(from: from.x, to: to.x, progress: t),
                y: interpolate(from: from.y, to: to.y, progress: t))
    }
    
    private func jitter(point: CGPoint, seed: UInt64, progress t: CGFloat, amplitude: CGFloat) -> CGPoint {
        // Perpendicular jitter relative to path direction, modulated by life progress
        let dx = toPoint.x - fromPoint.x
        let dy = toPoint.y - fromPoint.y
        let len = max(0.001, sqrt(dx*dx + dy*dy))
        let nx = -dy / len
        let ny = dx / len
        var s = seed
        let rand = (s.nextNormalized() * 2 - 1) // -1...1
        let amount = amplitude * (0.5 + 0.5 * sin(Double(t) * .pi))
        return CGPoint(x: point.x + nx * amount * rand, y: point.y + ny * amount * rand)
    }
    
    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        from + (to - from) * progress
    }
}

/// Stacking Coins Animation - For savings and wealth building
public struct StackingCoinsAnimation: View {
    @State private var coinOffsets: [CGFloat] = []
    private let numberOfCoins: Int
    private let coinSize: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(numberOfCoins: Int = 5, coinSize: CGFloat = 30) {
        self.numberOfCoins = numberOfCoins
        self.coinSize = coinSize
    }
    
    public var body: some View {
        VStack(spacing: -coinSize * 0.3) {
            ForEach(0..<numberOfCoins, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignTokens.Colors.tertiary400, DesignTokens.Colors.tertiary600],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: coinSize, height: coinSize)
                    .overlay(
                        Text("$")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignTokens.Colors.textInverse)
                    )
                    .offset(y: coinOffsets.indices.contains(index) ? coinOffsets[index] : (reduceMotion ? 0 : 100))
                    .animation(
                        reduceMotion ? .none :
                            MotionSystem.Easing.bounce
                            .delay(Double(index) * 0.2),
                        value: coinOffsets
                    )
            }
        }
        .onAppear {
            coinOffsets = Array(repeating: 0, count: numberOfCoins)
        }
    }
}

/// Chart Growth Animation - For portfolio and investment growth
public struct ChartGrowthAnimation: View {
    @State private var progress: CGFloat = 0.0
    
    private let dataPoints: [Double]
    private let color: Color
    private let animated: Bool
    private let smooth: Bool
    private let fillBelow: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        dataPoints: [Double],
        color: Color = DesignTokens.Colors.success,
        animated: Bool = true,
        smooth: Bool = true,
        fillBelow: Bool = false
    ) {
        self.dataPoints = dataPoints
        self.color = color
        self.animated = animated
        self.smooth = smooth
        self.fillBelow = fillBelow
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                let path = makePath(in: geometry.size)
                if fillBelow {
                    path.path
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.25), color.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(0.8)
                        .mask(
                            Rectangle()
                                .trim(from: 0, to: progress)
                                .scaleEffect(x: 1, y: 1, anchor: .leading)
                        )
                }
                
                path.path
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
            }
        }
        .onAppear {
            if animated && !reduceMotion {
                withAnimation(.easeOut(duration: MotionSystem.Duration.relaxed)) {
                    progress = 1.0
                }
            } else {
                progress = 1.0
            }
        }
    }
    
    private func makePath(in size: CGSize) -> (path: Path, minY: CGFloat, maxY: CGFloat) {
        var path = Path()
        guard !dataPoints.isEmpty else { return (path, 0, 0) }
        
        let maxValue = dataPoints.max() ?? 1.0
        let minValue = dataPoints.min() ?? 0.0
        let range = max(maxValue - minValue, 0.0001)
        let stepX = size.width / CGFloat(max(dataPoints.count - 1, 1))
        
        // Map points to view space
        let pts: [CGPoint] = dataPoints.enumerated().map { idx, value in
            let norm = (value - minValue) / range
            let x = CGFloat(idx) * stepX
            let y = size.height * (1 - CGFloat(norm))
            return CGPoint(x: x, y: y)
        }
        
        if smooth && pts.count >= 2 {
            path = catmullRomPath(points: pts, alpha: 0.5)
        } else {
            for (i, p) in pts.enumerated() {
                if i == 0 {
                    path.move(to: p)
                } else {
                    path.addLine(to: p)
                }
            }
        }
        
        // For area fill, close to bottom
        if fillBelow, let first = pts.first, let last = pts.last {
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: last.x, y: size.height))
            fillPath.addLine(to: CGPoint(x: first.x, y: size.height))
            fillPath.closeSubpath()
            return (fillPath, 0, size.height)
        }
        
        return (path, 0, size.height)
    }
    
    // Catmull–Rom spline for smooth curves
    private func catmullRomPath(points: [CGPoint], alpha: CGFloat = 0.5) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        let pts = [points.first!] + points + [points.last!]
        path.move(to: points.first!)
        
        for i in 1..<pts.count - 2 {
            let p0 = pts[i - 1]
            let p1 = pts[i]
            let p2 = pts[i + 1]
            let p3 = pts[i + 2]
            
            let d1 = hypot(p1.x - p0.x, p1.y - p0.y)
            let d2 = hypot(p2.x - p1.x, p2.y - p1.y)
            let d3 = hypot(p3.x - p2.x, p3.y - p2.y)
            
            let b1 = d1 > 0 ? pow(d1, 2 * alpha) : 0
            let b2 = d2 > 0 ? pow(d2, 2 * alpha) : 0
            let b3 = d3 > 0 ? pow(d3, 2 * alpha) : 0
            
            let m1 = CGPoint(
                x: (p2.x - p0.x) / (2 * (b1 + b2)) * b2 + p1.x,
                y: (p2.y - p0.y) / (2 * (b1 + b2)) * b2 + p1.y
            )
            let m2 = CGPoint(
                x: (p3.x - p1.x) / (2 * (b2 + b3)) * b2 + p2.x,
                y: (p3.y - p1.y) / (2 * (b2 + b3)) * b2 + p2.y
            )
            
            let control1 = CGPoint(
                x: p1.x + (m1.x - p1.x) / 3.0,
                y: p1.y + (m1.y - p1.y) / 3.0
            )
            let control2 = CGPoint(
                x: p2.x - (m2.x - p2.x) / 3.0,
                y: p2.y - (m2.y - p2.y) / 3.0
            )
            
            path.addCurve(to: p2, control1: control1, control2: control2)
        }
        
        return path
    }
}

/// Goal Progress Animation - Circular progress with celebration
public struct GoalProgressAnimation: View {
    @State private var currentProgress: Double = 0.0
    @State private var showCelebration = false
    @State private var showGlow = false
    @State private var previousTargetProgress: Double = 0.0
    
    private let targetProgress: Double
    private let goalName: String
    private let goalAmount: Double
    private let ringThickness: CGFloat
    private let milestones: [Double] = [0.25, 0.5, 0.75, 1.0]
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(progress: Double, goalName: String, goalAmount: Double, ringThickness: CGFloat = 14) {
        self.targetProgress = min(1.0, max(0.0, progress))
        self.goalName = goalName
        self.goalAmount = goalAmount
        self.ringThickness = ringThickness
    }
    
    public var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lineWidth: CGFloat = ringThickness
            let radius = (size / 2) - lineWidth / 2
            let isEmergency = goalName.localizedCaseInsensitiveContains("emergency")
            
            ZStack {
                // Background ring
                Circle()
                    .stroke(DesignTokens.Colors.neutral300, lineWidth: lineWidth)
                
                // Emergency Fund pulsing glow
                if isEmergency && !reduceMotion && targetProgress < 1.0 {
                    Circle()
                        .stroke(DesignTokens.Colors.warning.opacity(0.25), lineWidth: lineWidth)
                        .shadow(color: DesignTokens.Colors.warning.opacity(0.55),
                                radius: showGlow ? 24 : 8)
                        .animation(
                            .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                            value: showGlow
                        )
                        .onAppear { showGlow = true }
                }
                
                // Progress ring (gradient when Emergency Fund)
                Circle()
                    .trim(from: 0, to: currentProgress)
                    .stroke(
                        isEmergency
                        ? AnyShapeStyle(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    DesignTokens.Colors.warning,
                                    DesignTokens.Colors.primary500,
                                    DesignTokens.Colors.success
                                ]),
                                center: .center
                            )
                        )
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [progressColor, progressColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? .none : MotionSystem.Easing.smooth.delay(0.2), value: currentProgress)
                
                // Milestone ticks
                ForEach(milestones, id: \.self) { mark in
                    let angle = -90.0 + 360.0 * mark
                    let tickLength: CGFloat = 8
                    let outer = point(onCircleWithRadius: radius + lineWidth / 2, angleDegrees: angle)
                    let inner = point(onCircleWithRadius: radius + lineWidth / 2 - tickLength, angleDegrees: angle)
                    
                    Path { p in
                        p.move(to: inner)
                        p.addLine(to: outer)
                    }
                    .stroke(DesignTokens.Colors.neutral300.opacity(0.9), lineWidth: 2)
                    .opacity(mark <= currentProgress + 0.001 ? 1.0 : 0.5)
                }
                
                // Marker dot that follows progress
                if currentProgress > 0.0 {
                    let markerAngle = -90.0 + 360.0 * currentProgress
                    let markerPoint = point(onCircleWithRadius: radius, angleDegrees: markerAngle)
                    
                    Circle()
                        .fill(isEmergency ? DesignTokens.Colors.warning : progressColor)
                        .frame(width: 10, height: 10)
                        .position(markerPoint)
                        .shadow(color: (isEmergency ? DesignTokens.Colors.warning : progressColor).opacity(0.5), radius: 6)
                        .animation(reduceMotion ? .none : MotionSystem.Easing.gentle, value: currentProgress)
                }
                
                // Center content
                VStack(spacing: 6) {
                    // Tag for Emergency Fund
                    if isEmergency {
                        Text("Emergency Fund")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DesignTokens.Colors.warning.opacity(0.15))
                            .foregroundColor(DesignTokens.Colors.warning)
                            .clipShape(Capsule())
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        Text(goalName)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Amount
                    Text("$\(String(format: "%.0f", goalAmount * currentProgress))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(isEmergency ? DesignTokens.Colors.warning : progressColor)
                        .modifier(NumericTransition())
                    
                    Text("of $\(String(format: "%.0f", goalAmount))")
                        .font(.caption)
                        .foregroundColor(DesignTokens.Colors.textSecondary)
                }
                
                // Center badge icon for Emergency Fund
                if isEmergency {
                    Image(systemName: "piggy.bank.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignTokens.Colors.warning)
                        .opacity(0.2)
                        .scaleEffect(targetProgress >= 1.0 ? 1.0 : 0.95)
                        .animation(reduceMotion ? .none : MotionSystem.Easing.gentle, value: currentProgress)
                }
                
                // Celebration particles
                if showCelebration && !reduceMotion {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(DesignTokens.Colors.success)
                            .frame(width: 4, height: 4)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 60,
                                y: sin(Double(index) * .pi / 4) * 60
                            )
                            .scaleEffect(showCelebration ? 1.0 : 0.0)
                            .animation(
                                MotionSystem.Easing.bounce
                                    .delay(Double(index) * 0.1),
                                value: showCelebration
                            )
                    }
                }
            }
            .frame(width: size, height: size)
        }
        .onAppear {
            previousTargetProgress = currentProgress
            animateProgress()
        }
        .onChange(of: targetProgress) { _ in
            animateProgress()
        }
    }
    
    private var progressColor: Color {
        if targetProgress >= 1.0 {
            return DesignTokens.Colors.success
        } else if targetProgress >= 0.7 {
            return DesignTokens.Colors.warning
        } else {
            return DesignTokens.Colors.primary500
        }
    }
    
    private func animateProgress() {
        if reduceMotion {
            currentProgress = targetProgress
            previousTargetProgress = targetProgress
            return
        }
        
        // Use a spring when progress increases (feels like "money being added").
        if targetProgress > currentProgress {
            withAnimation(.interpolatingSpring(stiffness: 140, damping: 18)) {
                currentProgress = targetProgress
            }
        } else {
            withAnimation(.easeOut(duration: MotionSystem.Duration.relaxed)) {
                currentProgress = targetProgress
            }
        }
        
        previousTargetProgress = targetProgress
        
        if targetProgress >= 1.0 && !reduceMotion {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(MotionSystem.Duration.relaxed * 1_000_000_000))
                withAnimation(.spring()) {
                    showCelebration = true
                }
                if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                    _ = EmptyView()
                        .sensoryFeedback(.success, trigger: showCelebration)
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showCelebration = false
            }
        }
    }
    
    // Convert an angle in degrees (0° at 3 o'clock, positive CCW) to a point in local coordinates,
    // accounting for the view's center via GeometryReader (position used directly).
    private func point(onCircleWithRadius r: CGFloat, angleDegrees: Double) -> CGPoint {
        // GeometryReader will place this at the correct position using .position(_:)
        let radians = angleDegrees * .pi / 180.0
        let x = r * CGFloat(cos(radians)) + r + 10 / 2 // rough center adjustment; actual position() centers it
        let y = r * CGFloat(sin(radians)) + r + 10 / 2
        return CGPoint(x: x, y: y)
    }
}

/// Biometric Animation - For Face ID / Touch ID
public struct BiometricScanAnimation: View {
    @State private var isScanning = false
    
    private let biometricType: BiometricType
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public enum BiometricType {
        case faceID, touchID
    }
    
    public init(type: BiometricType = .faceID) {
        self.biometricType = type
    }
    
    public var body: some View {
        ZStack {
            // Base icon
            baseIcon
            
            // Scanning overlay (looping pulse)
            if isScanning && !reduceMotion {
                TimelineView(.animation) { context in
                    let elapsed = context.date.timeIntervalSinceReferenceDate
                    let phase = elapsed.truncatingRemainder(dividingBy: 2.0) / 2.0
                    let p = CGFloat(phase)
                    
                    Circle()
                        .stroke(
                            DesignTokens.Colors.primary500.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                        )
                        .scaleEffect(1.0 + p * 0.5)
                        .opacity(1.0 - p)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            isScanning = true
        }
    }
    
    @ViewBuilder
    private var baseIcon: some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(DesignTokens.Colors.primary500)
                .symbolEffect(.pulse, options: .repeating, value: isScanning && !reduceMotion)
        } else {
            Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(DesignTokens.Colors.primary500)
        }
    }
}

// MARK: - Motion Modifiers and Extensions

extension View {
    // MARK: - Entrance Animations (iOS 17/macOS 14+)
    public func slideInFromBottom(delay: Double = 0.0) -> some View {
        modifier(SlideInModifier(edge: .bottom, delay: delay))
    }
    public func slideInFromTop(delay: Double = 0.0) -> some View {
        modifier(SlideInModifier(edge: .top, delay: delay))
    }
    public func slideInFromLeading(delay: Double = 0.0) -> some View {
        modifier(SlideInModifier(edge: .leading, delay: delay))
    }
    public func slideInFromTrailing(delay: Double = 0.0) -> some View {
        modifier(SlideInModifier(edge: .trailing, delay: delay))
    }
    public func fadeInScale(delay: Double = 0.0) -> some View {
        modifier(FadeInScaleModifier(delay: delay))
    }
    public func bounceIn(delay: Double = 0.0) -> some View {
        modifier(BounceInModifier(delay: delay))
    }
    
    // MARK: - Interaction Animations
    public func buttonPress() -> some View {
        modifier(ButtonPressModifier())
    }
    public func cardHover() -> some View {
        modifier(CardHoverModifier())
    }
    
    // MARK: - Accessibility-Aware Animations
    public func respectsReducedMotion() -> some View {
        modifier(ReducedMotionModifier())
    }
}

// MARK: - Animation Modifiers (17+ implementations)

private struct SlideInState {
    var offset: CGSize
    var opacity: Double
}

private struct SlideInModifier: ViewModifier {
    let edge: Edge
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.motionSpeedScale) private var speedScale
    @Environment(\.motionDelayScale) private var delayScale
    @State private var trigger = false
    
    func body(content: Content) -> some View {
        let initial = SlideInState(offset: initialOffset(), opacity: 0)
        content
            .keyframeAnimator(initialValue: initial, trigger: trigger) { content, value in
                content
                    .offset(value.offset)
                    .opacity(value.opacity)
            } keyframes: { _ in
                // Build a single, unconditional set of keyframes. When reduceMotion is true,
                // we make durations zero and start at the final values.
                let durationScale: Double = reduceMotion ? 0.0 : 1.0 / max(0.001, speedScale)
                let startOffset: CGSize = reduceMotion ? .zero : initial.offset
                let overshootOffset = CGSize(
                    width: startOffset.width * 0.06,
                    height: startOffset.height * 0.06
                )
                let startOpacity: Double = reduceMotion ? 1.0 : 0.0
                
                KeyframeTrack(\.offset) {
                    CubicKeyframe(startOffset, duration: 0.0)
                    CubicKeyframe(.zero, duration: MotionSystem.Duration.normal * durationScale)
                    CubicKeyframe(overshootOffset, duration: MotionSystem.Duration.quick * durationScale)
                    CubicKeyframe(.zero, duration: MotionSystem.Duration.quick * durationScale)
                }
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(startOpacity, duration: 0.0)
                    CubicKeyframe(1.0, duration: MotionSystem.Duration.normal * durationScale)
                }
            }
            .task {
                // Delay the trigger
                let scaledDelay = (delay * max(0.0, delayScale))
                try? await Task.sleep(nanoseconds: UInt64(scaledDelay * 1_000_000_000))
                trigger = true
            }
    }
    
    private func initialOffset() -> CGSize {
        switch edge {
        case .bottom: return CGSize(width: 0, height: 50)
        case .top: return CGSize(width: 0, height: -50)
        case .leading: return CGSize(width: -50, height: 0)
        case .trailing: return CGSize(width: 50, height: 0)
        }
    }
}

private struct FadeInScaleModifier: ViewModifier {
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.motionDelayScale) private var delayScale
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .phaseAnimator([false, true], trigger: appeared) { content, on in
                content
                    .scaleEffect(on ? 1.0 : 0.92)
                    .opacity(on ? 1.0 : 0.0)
            } animation: { _ in
                let d = delay * max(0.0, delayScale)
                return reduceMotion ? .default : MotionSystem.Easing.gentle.delay(d)
            }
            .onAppear { appeared = true }
    }
}

private struct BounceInModifier: ViewModifier {
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.motionDelayScale) private var delayScale
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .phaseAnimator([false, true], trigger: appeared) { content, on in
                content.scaleEffect(on ? 1.0 : 0.0)
            } animation: { _ in
                let d = delay * max(0.0, delayScale)
                return reduceMotion ? .default : MotionSystem.Easing.bounce.delay(d)
            }
            .onAppear { appeared = true }
    }
}

private struct ButtonPressModifier: ViewModifier {
    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .phaseAnimator([false, true], trigger: isPressed) { content, pressed in
                content.scaleEffect(pressed ? 0.95 : 1.0)
            } animation: { _ in
                reduceMotion ? .default : .easeInOut(duration: MotionSystem.Duration.quick)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: isPressed)
            .onPressAction { pressing in
                isPressed = pressing
            }
    }
}

// Adapter: convert shadow token blur Double -> CGFloat expected by shadowToken API
private func cgShadow(_ s: (offset: CGSize, blur: CGFloat, opacity: Double)) -> (offset: CGSize, blur: CGFloat, opacity: Double) {
    (s.offset, s.blur, s.opacity)
}

private struct CardHoverModifier: ViewModifier {
    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        #if os(macOS) || os(iOS)
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadowToken(isHovered ? cgShadow(DesignTokens.Shadow.lg) : cgShadow(DesignTokens.Shadow.md))
            .animation(reduceMotion ? .none : MotionSystem.Easing.smooth, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            #if os(iOS)
            .hoverEffect(.lift)
            #endif
        #else
        content
        #endif
    }
}

private struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    func body(content: Content) -> some View {
        if reduceMotion {
            return AnyView(
                content.transaction { tx in
                    tx.animation = nil
                }
            )
        } else {
            return AnyView(content)
        }
    }
}

// MARK: - Helper Extensions

extension View {
    fileprivate func onPressAction(perform action: @escaping (Bool) -> Void) -> some View {
        modifier(PressActionModifier(action: action))
    }
}

private struct PressActionModifier: ViewModifier {
    let action: (Bool) -> Void
    @GestureState private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
            .onChange(of: isPressed, perform: action)
    }
}

// Numeric content transition helper
private struct NumericTransition: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}

// MARK: - Advanced Motion Extensions

public extension View {
    // MARK: Scroll-linked effects (iOS 17+/macOS 14+)
    func scrollFadeIn(threshold: CGFloat = 0.2) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            return AnyView(
                self.scrollTransition(axis: .vertical) { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .offset(y: phase.isIdentity ? 0 : 16)
                }
            )
        } else {
            return AnyView(self)
        }
    }
    
    func scrollScaleIn(minScale: CGFloat = 0.92) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            return AnyView(
                self.scrollTransition { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1.0 : minScale)
                        .opacity(phase.isIdentity ? 1.0 : 0.0)
                }
            )
        } else {
            return AnyView(self)
        }
    }
    
    func scrollParallax(depth: CGFloat = 12) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            return AnyView(
                self.visualEffect { content, proxy in
                    content.offset(y: (-proxy.frame(in: .global).minY / 300) * depth)
                }
            )
        } else {
            return AnyView(self)
        }
    }
    
    // MARK: Hover tilt (macOS + iPadOS pointer)
    func hoverTilt(maxAngle: CGFloat = 6, scale: CGFloat = 1.02) -> some View {
        #if os(macOS) || os(iOS)
        return self.modifier(HoverTiltModifier(maxAngle: maxAngle, scale: scale))
        #else
        return self
        #endif
    }
    
    // MARK: Presentation transitions
    static var toastTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    static var bannerTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    static var popTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        )
    }
    
    // MARK: Sensory feedback tokens
    func motionFeedback(_ type: MotionFeedback, trigger: Bool) -> some View {
        modifier(MotionFeedbackModifier(type: type, trigger: trigger))
    }
}

// MARK: - Hover Tilt Modifier
#if os(macOS) || os(iOS)
private struct HoverTiltModifier: ViewModifier {
    let maxAngle: CGFloat
    let scale: CGFloat
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        content
            .rotation3DEffect(.degrees(isHovered ? Double(maxAngle) : 0), axis: (x: 1, y: 0, z: 0))
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(.easeOut(duration: 0.2), value: isHovered)
            .onHover { isHovered = $0 }
        #else
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(.easeOut(duration: 0.2), value: isHovered)
            .onHover { isHovered = $0 }
        #endif
    }
}
#endif

// MARK: - Sensory Feedback
public enum MotionFeedback {
    case impactLight
    case impactMedium
    case impactHeavy
    case success
    case warning
    case error
}

private struct MotionFeedbackModifier: ViewModifier {
    let type: MotionFeedback
    let trigger: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            switch type {
            case .impactLight:
                content.sensoryFeedback(.impact(weight: .light), trigger: trigger)
            case .impactMedium:
                content.sensoryFeedback(.impact(weight: .medium), trigger: trigger)
            case .impactHeavy:
                content.sensoryFeedback(.impact(weight: .heavy), trigger: trigger)
            case .success:
                content.sensoryFeedback(.success, trigger: trigger)
            case .warning:
                content.sensoryFeedback(.warning, trigger: trigger)
            case .error:
                content.sensoryFeedback(.error, trigger: trigger)
            }
        } else {
            content // Pre-iOS 17/macOS 14: no-op fallback
        }
    }
}

// MARK: - Professional, universal, reusable motion primitives

// 1) EntranceStyle: a single, flexible entrance modifier
public enum EntranceStyle: Equatable {
    case fade(alpha: ClosedRange<Double> = 0.0...1.0)
    case slide(edge: Edge = .bottom, distance: CGFloat = 24)
    case scale(from: CGFloat = 0.92)
    case blur(radius: CGFloat = 8)
}

public extension View {
    func entrance(_ style: EntranceStyle, delay: Double = 0, duration: Double = MotionSystem.Duration.normal) -> some View {
        modifier(EntranceModifier(style: style, delay: delay, duration: duration))
    }
}

private struct EntranceModifier: ViewModifier {
    let style: EntranceStyle
    let delay: Double
    let duration: Double
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        Group {
            switch style {
            case .fade(let alpha):
                content
                    .opacity(appeared ? alpha.upperBound : alpha.lowerBound)
            case .slide(let edge, let distance):
                content
                    .offset(offset(for: edge, distance: appeared ? 0 : distance))
                    .opacity(appeared ? 1 : 0)
            case .scale(let from):
                content
                    .scaleEffect(appeared ? 1.0 : from)
                    .opacity(appeared ? 1 : 0)
            case .blur(let radius):
                content
                    .blur(radius: appeared ? 0 : radius)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    appeared = true
                }
            }
        }
    }
    
    private func offset(for edge: Edge, distance: CGFloat) -> CGSize {
        switch edge {
        case .top: return CGSize(width: 0, height: -distance)
        case .bottom: return CGSize(width: 0, height: distance)
        case .leading: return CGSize(width: -distance, height: 0)
        case .trailing: return CGSize(width: distance, height: 0)
        }
    }
}

// 2) Shimmer: for loading or emphasis
public extension View {
    func shimmer(active: Bool = true, speed: Double = 1.2, angle: Angle = .degrees(20), bandSize: CGFloat = 0.25) -> some View {
        modifier(ShimmerModifier(active: active, speed: speed, angle: angle, bandSize: bandSize))
    }
}

private struct ShimmerModifier: ViewModifier {
    let active: Bool
    let speed: Double
    let angle: Angle
    let bandSize: CGFloat
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1.0
    
    func body(content: Content) -> some View {
        content
            .overlay(gradientMask.mask(content))
            .onAppear {
                guard active, !reduceMotion else { return }
                withAnimation(.linear(duration: max(0.2, 2.0 / speed)).repeatForever(autoreverses: false)) {
                    phase = 2.0
                }
            }
    }
    
    private var gradientMask: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .white.opacity(0.0), location: max(0, phase - bandSize)),
                .init(color: .white.opacity(0.8), location: phase),
                .init(color: .white.opacity(0.0), location: min(1, phase + bandSize))
            ]),
            startPoint: UnitPoint(x: 0.0, y: 0.0),
            endPoint: UnitPoint(x: cos(angle.radians), y: sin(angle.radians))
        )
    }
}

// 3) SkeletonBlock: reusable loading placeholder
public struct SkeletonBlock: View {
    public enum ShapeStyle { case rounded(CGFloat), capsule, circle }
    let width: CGFloat?
    let height: CGFloat
    let style: ShapeStyle
    
    public init(width: CGFloat? = nil, height: CGFloat = 16, style: ShapeStyle = .rounded(8)) {
        self.width = width
        self.height = height
        self.style = style
    }
    
    public var body: some View {
        Group {
            switch style {
            case .rounded(let r):
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .fill(DesignTokens.Colors.neutral200)
            case .capsule:
                Capsule()
                    .fill(DesignTokens.Colors.neutral200)
            case .circle:
                Circle()
                    .fill(DesignTokens.Colors.neutral200)
            }
        }
        .frame(width: width, height: height)
        .shimmer()
    }
}

// 4) CountUpText: currency-friendly number animation
public struct CountUpText: View {
    let value: Double
    let format: NumberFormatter
    let duration: Double
    let easing: Animation
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayed: Double = 0
    
    public init(
        _ value: Double,
        numberStyle: NumberFormatter.Style = .decimal,
        duration: Double = MotionSystem.Duration.relaxed,
        easing: Animation = MotionSystem.Easing.gentle
    ) {
        self.value = value
        self.duration = duration
        self.easing = easing
        let nf = NumberFormatter()
        nf.numberStyle = numberStyle
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        self.format = nf
    }
    
    public var body: some View {
        Text(format.string(from: NSNumber(value: displayed)) ?? "\(displayed)")
            .onAppear {
                if reduceMotion {
                    displayed = value
                } else {
                    withAnimation(MotionSystem.animation(duration: duration, easing: easing)) {
                        displayed = value
                    }
                }
            }
            .onChange(of: value) { new in
                if reduceMotion {
                    displayed = new
                } else {
                    withAnimation(MotionSystem.animation(duration: duration, easing: easing)) {
                        displayed = new
                    }
                }
            }
    }
}

// 5) ConfettiEmitter: general-purpose celebration
public struct ConfettiEmitter: View {
    public struct Config {
        public var colors: [Color] = [DesignTokens.Colors.success, DesignTokens.Colors.primary500, DesignTokens.Colors.warning]
        public var count: Int = 24
        public var lifetime: ClosedRange<TimeInterval> = 0.8...1.6
        public var size: ClosedRange<CGFloat> = 3...6
        public var spread: ClosedRange<Double> = 0...(2 * .pi)
        public var speed: ClosedRange<Double> = 80...180
        
        public init() {}
    }
    
    let config: Config
    @State private var startTime: TimeInterval = 0
    
    public init(config: Config = Config()) {
        self.config = config
    }
    
    public var body: some View {
        TimelineView(.animation) { context in
            let now = context.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                if startTime == 0 { startTime = now }
                
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                for i in 0..<config.count {
                    var seed = UInt64(i &+ 1) &* 0x9E3779B97F4A7C15
                    let life = TimeInterval(seed.nextNormalized()) * (config.lifetime.upperBound - config.lifetime.lowerBound) + config.lifetime.lowerBound
                    let age = (now - startTime).truncatingRemainder(dividingBy: life)
                    let t = CGFloat(max(0, min(1, age / life)))
                    
                    let angle = Double(seed.nextNormalized()) * (config.spread.upperBound - config.spread.lowerBound) + config.spread.lowerBound
                    let speed = Double(seed.nextNormalized()) * (config.speed.upperBound - config.speed.lowerBound) + config.speed.lowerBound
                    let distance = CGFloat(speed * Double(t))
                    
                    let px = center.x + CGFloat(cos(angle)) * distance
                    let py = center.y + CGFloat(sin(angle)) * distance + t * 40 // slight gravity
                    
                    let s = seed.nextNormalized() * (config.size.upperBound - config.size.lowerBound) + config.size.lowerBound
                    let rect = CGRect(x: px - s/2, y: py - s/2, width: s, height: s)
                    let color = config.colors[Int(Double(config.colors.count) * Double(seed.nextNormalized())).clamped(to: 0...(config.colors.count - 1))]
                    
                    ctx.opacity = Double(sin(Double(t) * .pi)) // fade in/out
                    ctx.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// 6) BrandedAnimation: simple factory for existing branded animations
public struct BrandedAnimation: View {
    let type: BrandedAnimationType
    
    // Common knobs for reusability
    var size: CGSize = .init(width: 180, height: 180)
    var accent: Color = DesignTokens.Colors.primary500
    
    public init(_ type: BrandedAnimationType, size: CGSize = .init(width: 180, height: 180), accent: Color = DesignTokens.Colors.primary500) {
        self.type = type
        self.size = size
        self.accent = accent
    }
    
    public var body: some View {
        Group {
            switch type {
            case .moneyFlow:
                MoneyFlowAnimation(from: CGPoint(x: -50, y: 0), to: CGPoint(x: 50, y: 0), amount: 100)
            case .stackingCoins:
                StackingCoinsAnimation(numberOfCoins: 5, coinSize: min(size.width, size.height) / 6)
            case .chartGrowth:
                ChartGrowthAnimation(dataPoints: [100, 150, 120, 200, 250, 180, 300], color: accent, animated: true, smooth: true, fillBelow: true)
            case .goalProgress:
                GoalProgressAnimation(progress: 0.75, goalName: "Savings Goal", goalAmount: 10_000, ringThickness: 14)
            case .biometricScan:
                BiometricScanAnimation(type: .faceID)
            default:
                // Placeholder for yet-to-be-implemented types
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DesignTokens.Colors.backgroundSecondary)
                    .overlay(
                        VStack(spacing: 8) {
                            Icon("sparkles", context: .inline)
                                .foregroundColor(accent)
                            Text("\(String(describing: type))")
                                .font(.caption)
                                .foregroundColor(DesignTokens.Colors.textSecondary)
                        }
                    )
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

#if DEBUG
// MARK: - Motion System Preview
struct MotionSystem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Branded animations showcase
            BrandedAnimationsView()
                .previewDisplayName("Branded Animations")
            
            // Motion components showcase
            MotionComponentsView()
                .previewDisplayName("Motion Components")
        }
    }
}

struct BrandedAnimationsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                
                // Money Flow Animation
                VStack {
                    Text("Money Flow Animation")
                        .font(.headline)
                    
                    ZStack {
                        Rectangle()
                            .fill(DesignTokens.Colors.backgroundSecondary)
                            .frame(height: 100)
                            .cornerRadius(DesignTokens.BorderRadius.md)
                        
                        MoneyFlowAnimation(
                            from: CGPoint(x: -50, y: 0),
                            to: CGPoint(x: 50, y: 0),
                            amount: 125.50
                        )
                    }
                    .frame(height: 100)
                }
                
                // Stacking Coins Animation
                VStack {
                    Text("Stacking Coins Animation")
                        .font(.headline)
                    
                    StackingCoinsAnimation(numberOfCoins: 4, coinSize: 25)
                        .frame(height: 120)
                }
                
                // Chart Growth Animation
                VStack {
                    Text("Chart Growth Animation")
                        .font(.headline)
                    
                    ChartGrowthAnimation(
                        dataPoints: [100, 150, 120, 200, 250, 180, 300, 320],
                        color: DesignTokens.Colors.success,
                        animated: true,
                        smooth: true,
                        fillBelow: true
                    )
                    .frame(height: 100)
                }
                
                // Goal Progress Animation
                VStack {
                    Text("Goal Progress Animation")
                        .font(.headline)
                    
                    GoalProgressAnimation(
                        progress: 0.75,
                        goalName: "Emergency Fund",
                        goalAmount: 10000,
                        ringThickness: 14
                    )
                    .frame(width: 180, height: 180)
                }
                
                // Biometric Animation
                VStack {
                    Text("Biometric Scan Animation")
                        .font(.headline)
                    
                    BiometricScanAnimation(type: .faceID)
                        .frame(width: 100, height: 100)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Branded Animations")
    }
}

struct MotionComponentsView: View {
    @State private var toggle = false
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignTokens.Spacing.lg) {
                
                ForEach(0..<10) { index in
                    FinancialCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Transaction \(index + 1)")
                                    .font(.headline)
                                Text("Coffee Shop")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("-$4.50")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignTokens.Colors.danger)
                        }
                    }
                    .slideInFromTrailing(
                        delay: MotionSystem.staggeredDelay(
                            index: index,
                            count: 10,
                            base: MotionSystem.Delay.short,
                            curve: .easeInCluster
                        )
                    )
                    .cardHover()
                    .scrollFadeIn()
                    .hoverTilt()
                }
                
                Button(toggle ? "Tap for Medium Impact" : "Tap for Light Impact") {
                    toggle.toggle()
                }
                .padding()
                .background(DesignTokens.Colors.backgroundSecondary)
                .cornerRadius(DesignTokens.BorderRadius.md)
                .motionFeedback(toggle ? .impactMedium : .impactLight, trigger: toggle)
            }
            .padding()
        }
        .navigationTitle("Motion Components")
        .motionSpeedScale(1.0)
        .motionDelayScale(1.0)
    }
}
#endif

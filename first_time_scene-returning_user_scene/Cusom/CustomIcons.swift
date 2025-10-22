//
//  CustomIcons.swift
//  MyApp
//
//  Custom icon shapes drawn with SwiftUI
//  Following SF Symbols design principles

import SwiftUI
import Combine
import Foundation
import CoreGraphics

// MARK: - Custom Icon Shapes
/// Collection of custom-drawn icons for app-specific needs
struct CustomIcons {

    // MARK: - Home Icon
    /// Custom home icon shape - house with roof
    struct HomeIcon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height

            // Roof (triangle)
            path.move(to: CGPoint(x: width * 0.5, y: height * 0.15))
            path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.45))
            path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.45))
            path.closeSubpath()

            // House body (rectangle)
            path.addRect(CGRect(
                x: width * 0.25,
                y: height * 0.4,
                width: width * 0.5,
                height: height * 0.45
            ))

            // Door
            path.addRect(CGRect(
                x: width * 0.42,
                y: height * 0.6,
                width: width * 0.16,
                height: height * 0.25
            ))

            return path
        }
    }

    // MARK: - Profile Icon
    /// Custom profile/user icon - circle with person silhouette
    struct ProfileIcon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height
            let centerX = width / 2

            // Outer circle
            path.addEllipse(in: CGRect(
                x: width * 0.1,
                y: height * 0.1,
                width: width * 0.8,
                height: height * 0.8
            ))

            // Head circle
            path.addEllipse(in: CGRect(
                x: width * 0.35,
                y: height * 0.25,
                width: width * 0.3,
                height: height * 0.3
            ))

            // Shoulders (arc)
            path.move(to: CGPoint(x: width * 0.25, y: height * 0.75))
            path.addQuadCurve(
                to: CGPoint(x: width * 0.75, y: height * 0.75),
                control: CGPoint(x: centerX, y: height * 0.55)
            )

            return path
        }
    }

    // MARK: - Settings Icon
    /// Custom settings icon - gear with 8 teeth
    struct SettingsIcon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) * 0.35
            let innerRadius = radius * 0.6
            let teethCount = 8

            // Draw gear teeth
            for i in 0..<teethCount {
                let angle = (Double(i) * 2.0 * .pi) / Double(teethCount)
                let nextAngle = (Double(i + 1) * 2.0 * .pi) / Double(teethCount)

                // Outer tooth point
                let outerPoint = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )

                // Inner valley point
                let innerPoint = CGPoint(
                    x: center.x + cos(angle + .pi / Double(teethCount)) * innerRadius,
                    y: center.y + sin(angle + .pi / Double(teethCount)) * innerRadius
                )

                if i == 0 {
                    path.move(to: outerPoint)
                } else {
                    path.addLine(to: outerPoint)
                }
                path.addLine(to: innerPoint)
            }
            path.closeSubpath()

            // Center circle
            path.addEllipse(in: CGRect(
                x: center.x - radius * 0.3,
                y: center.y - radius * 0.3,
                width: radius * 0.6,
                height: radius * 0.6
            ))

            return path
        }
    }

    // MARK: - Plus Icon
    /// Custom plus icon for add actions
    struct PlusIcon: Shape {
        var lineWidth: CGFloat = 0.15

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height
            let lineThickness = min(width, height) * lineWidth

            // Horizontal bar
            path.addRect(CGRect(
                x: width * 0.2,
                y: (height - lineThickness) / 2,
                width: width * 0.6,
                height: lineThickness
            ))

            // Vertical bar
            path.addRect(CGRect(
                x: (width - lineThickness) / 2,
                y: height * 0.2,
                width: lineThickness,
                height: height * 0.6
            ))

            return path
        }
    }

    // MARK: - Checkmark Icon
    /// Custom checkmark for success states
    struct CheckmarkIcon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height

            path.move(to: CGPoint(x: width * 0.2, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.7))
            path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.25))

            return path
        }
    }

    // MARK: - Heart Icon
    /// Custom heart icon for favorites/likes
    struct HeartIcon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height

            // Left arc
            path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
            path.addCurve(
                to: CGPoint(x: width * 0.2, y: height * 0.2),
                control1: CGPoint(x: width * 0.4, y: height * 0.15),
                control2: CGPoint(x: width * 0.3, y: height * 0.15)
            )
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.85),
                control1: CGPoint(x: width * 0.1, y: height * 0.35),
                control2: CGPoint(x: width * 0.3, y: height * 0.65)
            )

            // Right arc
            path.addCurve(
                to: CGPoint(x: width * 0.8, y: height * 0.2),
                control1: CGPoint(x: width * 0.7, y: height * 0.65),
                control2: CGPoint(x: width * 0.9, y: height * 0.35)
            )
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.3),
                control1: CGPoint(x: width * 0.7, y: height * 0.15),
                control2: CGPoint(x: width * 0.6, y: height * 0.15)
            )

            return path
        }
    }

    // MARK: - Bell Icon
    /// Custom notification bell icon
    struct BellIcon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height

            // Bell body
            path.move(to: CGPoint(x: width * 0.5, y: height * 0.2))
            path.addCurve(
                to: CGPoint(x: width * 0.2, y: height * 0.65),
                control1: CGPoint(x: width * 0.3, y: height * 0.3),
                control2: CGPoint(x: width * 0.2, y: height * 0.5)
            )
            path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.65))
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.2),
                control1: CGPoint(x: width * 0.8, y: height * 0.5),
                control2: CGPoint(x: width * 0.7, y: height * 0.3)
            )

            // Bell rim
            path.addRect(CGRect(
                x: width * 0.15,
                y: height * 0.65,
                width: width * 0.7,
                height: height * 0.05
            ))

            // Bell clapper
            path.addEllipse(in: CGRect(
                x: width * 0.45,
                y: height * 0.75,
                width: width * 0.1,
                height: width * 0.1
            ))

            return path
        }
    }
}

// MARK: - Icon View Wrapper
/// Wrapper view for easily using custom icons with consistent sizing
struct CustomIconView: View {
    enum IconType {
        case home, profile, settings, plus, checkmark, heart, bell
    }

    let type: IconType
    let size: CGFloat
    let color: Color
    let filled: Bool

    init(_ type: IconType, size: CGFloat = 24, color: Color = .primary, filled: Bool = true) {
        self.type = type
        self.size = size
        self.color = color
        self.filled = filled
    }

    var body: some View {
        Group {
            switch type {
            case .home:
                iconShape(CustomIcons.HomeIcon())
            case .profile:
                iconShape(CustomIcons.ProfileIcon())
            case .settings:
                iconShape(CustomIcons.SettingsIcon())
            case .plus:
                iconShape(CustomIcons.PlusIcon())
            case .checkmark:
                iconShape(CustomIcons.CheckmarkIcon())
            case .heart:
                iconShape(CustomIcons.HeartIcon())
            case .bell:
                iconShape(CustomIcons.BellIcon())
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func iconShape<S: Shape>(_ shape: S) -> some View {
        if filled {
            shape
                .fill(color)
        } else {
            shape
                .stroke(color, lineWidth: 2)
        }
    }
}

// MARK: - Preview
struct CustomIcons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            HStack(spacing: 30) {
                CustomIconView(.home, size: 44)
                CustomIconView(.profile, size: 44)
                CustomIconView(.settings, size: 44)
            }
            HStack(spacing: 30) {
                CustomIconView(.plus, size: 44, color: .green)
                CustomIconView(.checkmark, size: 44, color: .green)
                CustomIconView(.heart, size: 44, color: .red)
            }
            HStack(spacing: 30) {
                CustomIconView(.bell, size: 44, color: .orange)
                CustomIconView(.home, size: 44, filled: false)
                CustomIconView(.heart, size: 44, color: .pink, filled: false)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

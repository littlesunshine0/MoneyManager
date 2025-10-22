// IconsMotionBridge.swift
import SwiftUI

// Bridge Icon -> LegacyIcon so existing `Icon(...)` calls work everywhere
public typealias Icon = LegacyIcon
public typealias IconContext = LegacyIconContext

// Minimal “entrance” motion bridge so calls like `.entrance(.scale(...))` compile.
// We map them onto your existing simple motion helpers.
public enum EntranceKind {
    case scale(from: CGFloat = 0.92)
    case slide(edge: Edge = .bottom, distance: CGFloat = 24)
}

public extension View {
    func entrance(_ kind: EntranceKind, delay: Double = 0) -> some View {
        switch kind {
        case .scale(let from):
            // Approximate with your fadeInScale shim
            return AnyView(self
                .scaleEffect(from)
                .fadeInScale(delay: delay)
            )
        case .slide(let edge, let distance):
            // Approximate with your slide shims
            switch edge {
            case .top:
                return AnyView(self.slideInFromTop(delay: delay))
            case .bottom:
                return AnyView(self.slideInFromBottom(delay: delay))
            case .leading:
                return AnyView(self.slideInFromLeading(delay: delay))
            case .trailing:
                return AnyView(self.slideInFromTrailing(delay: delay))
            }
        }
    }
}

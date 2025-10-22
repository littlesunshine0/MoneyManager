import SwiftUI



// MARK: - Accessibility System minimal shim (renamed to avoid clashing with real AccessibilitySystem)
public enum AccessibilitySystemShim {
    public final class AccessibilityManager: ObservableObject {
        public init() {}
        public func provideTactileFeedback(for event: HapticEvent) {
            // no-op shim
        }
    }
    public enum HapticEvent {
        case buttonTapped
    }
}

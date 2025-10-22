import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AudioToolbox)
import AudioToolbox
#endif

// MARK: - Accessibility System
public struct AccessibilitySystem {
    
    // MARK: - Accessibility Preferences Manager
    public class AccessibilityManager: ObservableObject {
        
        // MARK: - Published Properties
        @Published public var isVoiceOverEnabled: Bool = false
        @Published public var isReduceMotionEnabled: Bool = false
        @Published public var isReduceTransparencyEnabled: Bool = false
        @Published public var isHighContrastEnabled: Bool = false
        @Published public var isDifferentiateWithoutColorEnabled: Bool = false
        @Published public var isAssistiveTouchEnabled: Bool = false
        @Published public var isSwitchControlEnabled: Bool = false
        @Published public var currentDynamicTypeSize: DynamicTypeSize = .large
        
        // MARK: - Financial-Specific Accessibility
        @Published public var useSoundForTransactions: Bool = true
        @Published public var useHapticsForImportantActions: Bool = true
        @Published public var announceBalanceChanges: Bool = false
        @Published public var useLargerTapTargets: Bool = false
        @Published public var useHighContrastNumbers: Bool = false
        
        private var cancellables = Set<AnyCancellable>()
        
        public init() {
            setupAccessibilityObservers()
            updateAccessibilitySettings()
        }
        
        // MARK: - System Observers
        private func setupAccessibilityObservers() {
            #if canImport(UIKit)
            // VoiceOver status
            NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)
                .sink { [weak self] _ in
                    self?.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
                }
                .store(in: &cancellables)
            
            // Reduce Motion
            NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
                .sink { [weak self] _ in
                    self?.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
                }
                .store(in: &cancellables)
            
            // Reduce Transparency
            NotificationCenter.default.publisher(for: UIAccessibility.reduceTransparencyStatusDidChangeNotification)
                .sink { [weak self] _ in
                    self?.isReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
                }
                .store(in: &cancellables)
            
            // High Contrast
            NotificationCenter.default.publisher(for: UIAccessibility.darkerSystemColorsStatusDidChangeNotification)
                .sink { [weak self] _ in
                    self?.isHighContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
                }
                .store(in: &cancellables)
            
            // Differentiate Without Color
            NotificationCenter.default.publisher(for: UIAccessibility.differentiateWithoutColorDidChangeNotification)
                .sink { [weak self] _ in
                    self?.isDifferentiateWithoutColorEnabled = UIAccessibility.shouldDifferentiateWithoutColor
                }
                .store(in: &cancellables)
            
            // Assistive Touch
            NotificationCenter.default.publisher(for: UIAccessibility.assistiveTouchStatusDidChangeNotification)
                .sink { [weak self] _ in
                    self?.isAssistiveTouchEnabled = UIAccessibility.isAssistiveTouchRunning
                }
                .store(in: &cancellables)
            
            // Switch Control
            NotificationCenter.default.publisher(for: UIAccessibility.switchControlStatusDidChangeNotification)
                .sink { [weak self] _ in
                    self?.isSwitchControlEnabled = UIAccessibility.isSwitchControlRunning
                }
                .store(in: &cancellables)
            #endif
        }
        
        private func updateAccessibilitySettings() {
            #if canImport(UIKit)
            isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
            isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
            isReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
            isHighContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
            isDifferentiateWithoutColorEnabled = UIAccessibility.shouldDifferentiateWithoutColor
            isAssistiveTouchEnabled = UIAccessibility.isAssistiveTouchRunning
            isSwitchControlEnabled = UIAccessibility.isSwitchControlRunning
            #else
            isVoiceOverEnabled = false
            isReduceMotionEnabled = false
            isReduceTransparencyEnabled = false
            isHighContrastEnabled = false
            isDifferentiateWithoutColorEnabled = false
            isAssistiveTouchEnabled = false
            isSwitchControlEnabled = false
            #endif
        }
        
        // MARK: - Accessibility Helpers
        public func announceBalanceChange(from oldBalance: Double, to newBalance: Double, accountName: String) {
            guard isVoiceOverEnabled && announceBalanceChanges else { return }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            
            let oldBalanceString = formatter.string(from: NSNumber(value: oldBalance)) ?? "$\(oldBalance)"
            let newBalanceString = formatter.string(from: NSNumber(value: newBalance)) ?? "$\(newBalance)"
            
            let announcement = "\(accountName) balance updated from \(oldBalanceString) to \(newBalanceString)"
            
            #if canImport(UIKit)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
            #endif
        }
        
        public func announceTransactionAdded(_ transaction: TransactionAccessibilityInfo) {
            guard isVoiceOverEnabled else { return }
            let announcement = transaction.accessibilityAnnouncement
            #if canImport(UIKit)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
            #endif
        }
        
        public func provideTactileFeedback(for action: AccessibleAction) {
            guard useHapticsForImportantActions else { return }
            #if canImport(UIKit)
            let impactGenerator: UIImpactFeedbackGenerator
            
            switch action {
            case .transactionAdded, .budgetCreated, .goalReached:
                impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            case .budgetExceeded, .errorOccurred:
                impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
            case .buttonTapped, .itemSelected:
                impactGenerator = UIImpactFeedbackGenerator(style: .light)
            }
            
            impactGenerator.impactOccurred()
            #endif
        }
        
        public func provideSoundFeedback(for action: AccessibleAction) {
            guard useSoundForTransactions else { return }
            #if canImport(AudioToolbox)
            let soundID: SystemSoundID
            
            switch action {
            case .transactionAdded:
                soundID = 1004 // SMS received sound
            case .goalReached:
                soundID = 1005 // Achievement sound
            case .budgetExceeded:
                soundID = 1006 // Warning sound
            case .errorOccurred:
                soundID = 1007 // Error sound
            default:
                return // No sound for other actions
            }
            
            AudioServicesPlaySystemSound(soundID)
            #endif
        }
    }
    
    // MARK: - Accessibility Labels and Descriptions
    public struct Labels {
        
        // MARK: - Financial Labels
        public static func accountBalance(_ balance: Double, accountName: String) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            let balanceString = formatter.string(from: NSNumber(value: balance)) ?? "$\(balance)"
            return "\(accountName), balance \(balanceString)"
        }
        
        public static func transactionAmount(_ amount: Double, isIncome: Bool) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            let amountString = formatter.string(from: NSNumber(value: abs(amount))) ?? "$\(abs(amount))"
            let type = isIncome ? "income" : "expense"
            return "\(type) of \(amountString)"
        }
        
        public static func budgetProgress(_ spent: Double, _ total: Double, category: String) -> String {
            let percentage = (spent / total) * 100
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            let spentString = formatter.string(from: NSNumber(value: spent)) ?? "$\(spent)"
            let totalString = formatter.string(from: NSNumber(value: total)) ?? "$\(total)"
            
            return "\(category) budget: \(spentString) of \(totalString) used, \(Int(percentage)) percent"
        }
        
        public static func goalProgress(_ current: Double, _ target: Double, goalName: String) -> String {
            let percentage = (current / target) * 100
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            let currentString = formatter.string(from: NSNumber(value: current)) ?? "$\(current)"
            let targetString = formatter.string(from: NSNumber(value: target)) ?? "$\(target)"
            
            return "\(goalName): \(currentString) of \(targetString), \(Int(percentage)) percent complete"
        }
        
        // MARK: - Interface Labels
        public static func navigationButton(_ title: String, _ destination: String) -> String {
            return "\(title), navigates to \(destination)"
        }
        
        public static func actionButton(_ title: String, _ action: String) -> String {
            return "\(title), \(action)"
        }
        
        public static func formField(_ label: String, _ value: String?, isRequired: Bool = false) -> String {
            let requiredText = isRequired ? ", required" : ""
            if let value = value, !value.isEmpty {
                return "\(label), current value \(value)\(requiredText)"
            } else {
                return "\(label), no value entered\(requiredText)"
            }
        }
    }
    
    // MARK: - Accessibility Traits Helper
    public struct Traits {
        public static let accountCard: AccessibilityTraits = [.isButton, .isSummaryElement]
        public static let transactionRow: AccessibilityTraits = [.isButton]
        public static let budgetProgress: AccessibilityTraits = [.updatesFrequently]
        public static let currencyAmount: AccessibilityTraits = [.isStaticText]
        public static let actionButton: AccessibilityTraits = [.isButton]
        public static let navigationLink: AccessibilityTraits = [.isButton, .isLink]
        // .isKeyboardKey may not exist on all platforms; omit to avoid compile errors
        public static let formInput: AccessibilityTraits = []
        public static let chart: AccessibilityTraits = [.isImage, .updatesFrequently]
    }
}

// MARK: - Granular Haptics Namespace (unified from auth shim)
public extension AccessibilitySystem {
    enum Haptics {
        public enum Event {
            case goalReached
            case success
            case warning
            case error
            case itemSelected
            case impactLight
            case impactMedium
            case impactHeavy
            case buttonTapped
        }
    }
}

// MARK: - AccessibilityManager granular haptics support
public extension AccessibilitySystem.AccessibilityManager {
    @MainActor
    func provideTactileFeedback(for event: AccessibilitySystem.Haptics.Event) {
        #if os(iOS) || os(tvOS) || os(visionOS)
        switch event {
        case .goalReached, .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .itemSelected:
            UISelectionFeedbackGenerator().selectionChanged()
        case .impactLight, .buttonTapped:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .impactMedium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .impactHeavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        #else
        _ = event
        #endif
    }
    
    // Optional: richer mapping for AccessibleAction
    @MainActor
    func provideEnhancedTactileFeedback(for action: AccessibleAction) {
        switch action {
        case .goalReached:
            provideTactileFeedback(for: .success)
        case .budgetExceeded:
            provideTactileFeedback(for: .warning)
        case .errorOccurred:
            provideTactileFeedback(for: .error)
        case .transactionAdded, .budgetCreated:
            provideTactileFeedback(for: .impactMedium)
        case .buttonTapped, .itemSelected:
            provideTactileFeedback(for: .impactLight)
        }
    }
}

// MARK: - Accessible Action Types
public enum AccessibleAction {
    case transactionAdded
    case budgetCreated
    case goalReached
    case budgetExceeded
    case errorOccurred
    case buttonTapped
    case itemSelected
}

// MARK: - Transaction Accessibility Info
public struct TransactionAccessibilityInfo {
    let amount: Double
    let merchant: String
    let category: String
    let isIncome: Bool
    let date: Date
    
    var accessibilityAnnouncement: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let amountString = formatter.string(from: NSNumber(value: abs(amount))) ?? "$\(abs(amount))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: date)
        
        let type = isIncome ? "income" : "expense"
        
        return "New \(type) added: \(amountString) from \(merchant) in \(category) category on \(dateString)"
    }
}

// MARK: - Accessibility View Modifiers

public struct AccessibilityModifiers {
    
    // MARK: - Financial Amount Modifier
    public struct FinancialAmountModifier: ViewModifier {
        let amount: Double
        let context: String
        let isIncome: Bool
        
        public func body(content: Content) -> some View {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AccessibilitySystem.Labels.transactionAmount(amount, isIncome: isIncome))
                .accessibilityValue(context)
                .accessibilityAddTraits(AccessibilitySystem.Traits.currencyAmount)
        }
    }
    
    // MARK: - Account Card Modifier
    public struct AccountCardModifier: ViewModifier {
        let accountName: String
        let balance: Double
        let accountType: String
        let onTap: () -> Void
        
        public func body(content: Content) -> some View {
            content
                .accessibilityElement(children: .combine)
                .accessibilityLabel(AccessibilitySystem.Labels.accountBalance(balance, accountName: accountName))
                .accessibilityHint("Double tap to view account details")
                .accessibilityAddTraits(AccessibilitySystem.Traits.accountCard)
                .accessibilityAction(named: "View Details") {
                    onTap()
                }
        }
    }
    
    // MARK: - Budget Progress Modifier
    public struct BudgetProgressModifier: ViewModifier {
        let spent: Double
        let total: Double
        let category: String
        
        public func body(content: Content) -> some View {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AccessibilitySystem.Labels.budgetProgress(spent, total, category: category))
                .accessibilityAddTraits(AccessibilitySystem.Traits.budgetProgress)
        }
    }
    
    // MARK: - Goal Progress Modifier
    public struct GoalProgressModifier: ViewModifier {
        let current: Double
        let target: Double
        let goalName: String
        
        public func body(content: Content) -> some View {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AccessibilitySystem.Labels.goalProgress(current, target, goalName: goalName))
                .accessibilityAddTraits(AccessibilitySystem.Traits.budgetProgress)
        }
    }
    
    // MARK: - Enhanced Button Modifier
    public struct EnhancedButtonModifier: ViewModifier {
        let title: String
        let action: String
        let isEnabled: Bool
        @EnvironmentObject var accessibilityManager: AccessibilitySystem.AccessibilityManager
        
        public func body(content: Content) -> some View {
            content
                .accessibilityLabel(AccessibilitySystem.Labels.actionButton(title, action))
                .accessibilityAddTraits(AccessibilitySystem.Traits.actionButton)
                .disabled(!isEnabled)
                .accessibilityAction(named: title) {
                    if isEnabled {
                        accessibilityManager.provideTactileFeedback(for: .buttonTapped)
                    }
                }
        }
    }
}

// MARK: - SwiftUI View Extensions
extension View {
    
    // MARK: - Financial Accessibility Modifiers
    
    public func accessibleAmount(_ amount: Double, context: String = "", isIncome: Bool = false) -> some View {
        modifier(AccessibilityModifiers.FinancialAmountModifier(
            amount: amount,
            context: context,
            isIncome: isIncome
        ))
    }
    
    public func accessibleAccountCard(
        accountName: String,
        balance: Double,
        accountType: String,
        onTap: @escaping () -> Void
    ) -> some View {
        modifier(AccessibilityModifiers.AccountCardModifier(
            accountName: accountName,
            balance: balance,
            accountType: accountType,
            onTap: onTap
        ))
    }
    
    public func accessibleBudgetProgress(spent: Double, total: Double, category: String) -> some View {
        modifier(AccessibilityModifiers.BudgetProgressModifier(
            spent: spent,
            total: total,
            category: category
        ))
    }
    
    public func accessibleGoalProgress(current: Double, target: Double, goalName: String) -> some View {
        modifier(AccessibilityModifiers.GoalProgressModifier(
            current: current,
            target: target,
            goalName: goalName
        ))
    }
    
    public func accessibleButton(title: String, action: String, isEnabled: Bool = true) -> some View {
        modifier(AccessibilityModifiers.EnhancedButtonModifier(
            title: title,
            action: action,
            isEnabled: isEnabled
        ))
    }
    
    // MARK: - Focus Management
    
    public func focusable(identifier: String, onFocus: @escaping () -> Void = {}) -> some View {
        #if canImport(UIKit)
        return self
            .accessibilityIdentifier(identifier)
            .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.elementFocusedNotification)) { notification in
                if let element = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? UIAccessibilityElement,
                   element.accessibilityIdentifier == identifier {
                    onFocus()
                }
            }
        #else
        return self
        #endif
    }
    
    // MARK: - Dynamic Type Support
    
    public func supportsDynamicType(minimumSize: DynamicTypeSize = .xSmall, maximumSize: DynamicTypeSize = .accessibility5) -> some View {
        self.dynamicTypeSize(minimumSize...maximumSize)
    }
    
    // MARK: - High Contrast Support
    
    public func highContrastAdjusted(normalColor: Color, highContrastColor: Color) -> some View {
        #if canImport(UIKit)
        return self.foregroundColor(UIAccessibility.isDarkerSystemColorsEnabled ? highContrastColor : normalColor)
        #else
        return self.foregroundColor(normalColor)
        #endif
    }
    
    // MARK: - Reduce Motion Support
    
    public func motionSafe() -> some View {
        #if canImport(UIKit)
        if UIAccessibility.isReduceMotionEnabled {
            return AnyView(self.animation(.none, value: UUID()))
        } else {
            return AnyView(self)
        }
        #else
        return self
        #endif
    }
}

// MARK: - Accessibility Testing Support
#if DEBUG
public struct AccessibilityTester: View {
    @StateObject private var accessibilityManager = AccessibilitySystem.AccessibilityManager()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("Accessibility Status") {
                    FeatureRow(title: "VoiceOver", isEnabled: accessibilityManager.isVoiceOverEnabled)
                    FeatureRow(title: "Reduce Motion", isEnabled: accessibilityManager.isReduceMotionEnabled)
                    FeatureRow(title: "High Contrast", isEnabled: accessibilityManager.isHighContrastEnabled)
                    FeatureRow(title: "Reduce Transparency", isEnabled: accessibilityManager.isReduceTransparencyEnabled)
                    FeatureRow(title: "Differentiate Without Color", isEnabled: accessibilityManager.isDifferentiateWithoutColorEnabled)
                }
                
                Section("Financial Accessibility Examples") {
                    // Account Card Example
                    FinancialCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Checking Account")
                                    .font(.headline)
                                Text("Wells Fargo ****1234")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("$2,345.67")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignTokens.Colors.success)
                                .accessibleAmount(2345.67, context: "account balance")
                        }
                    }
                    .accessibleAccountCard(
                        accountName: "Checking Account",
                        balance: 2345.67,
                        accountType: "Wells Fargo",
                        onTap: {}
                    )
                    
                    // Budget Progress Example
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Food & Dining")
                                .font(.headline)
                            Spacer()
                            Text("$450 / $600")
                                .font(.subheadline)
                        }
                        
                        ProgressView(value: 0.75)
                            .progressViewStyle(LinearProgressViewStyle(tint: DesignTokens.Colors.warning))
                    }
                    .accessibleBudgetProgress(spent: 450, total: 600, category: "Food & Dining")
                    
                    // Goal Progress Example
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Emergency Fund")
                                .font(.headline)
                            Text("75% Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("$7,500 / $10,000")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .accessibleGoalProgress(current: 7500, target: 10000, goalName: "Emergency Fund")
                }
                
                Section("Actions") {
                    Button("Test Transaction Sound") {
                        accessibilityManager.provideSoundFeedback(for: .transactionAdded)
                    }
                    .accessibleButton(title: "Test Transaction Sound", action: "plays transaction sound")
                    
                    Button("Test Haptic Feedback") {
                        accessibilityManager.provideTactileFeedback(for: .transactionAdded)
                    }
                    .accessibleButton(title: "Test Haptic Feedback", action: "provides haptic feedback")
                    
                    Button("Test Announcement") {
                        accessibilityManager.announceBalanceChange(
                            from: 1000,
                            to: 950,
                            accountName: "Checking Account"
                        )
                    }
                    .accessibleButton(title: "Test Announcement", action: "announces balance change")
                }
            }
            .navigationTitle("Accessibility Tester")
        }
        .environmentObject(accessibilityManager)
    }
    
    private struct FeatureRow: View {
        let title: String
        let isEnabled: Bool
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Text(isEnabled ? "Enabled" : "Disabled")
                    .foregroundColor(isEnabled ? DesignTokens.Colors.success : DesignTokens.Colors.textSecondary)
            }
        }
    }
}
#endif

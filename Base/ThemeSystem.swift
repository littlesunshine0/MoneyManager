import SwiftUI
import Combine
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Theme Protocol
public protocol Theme {
    var name: String { get }
    var colorScheme: ColorScheme { get }
    
    // MARK: - Primary Colors
    var primaryColor: Color { get }
    var primaryColorVariant: Color { get }
    var secondaryColor: Color { get }
    var secondaryColorVariant: Color { get }
    
    // MARK: - Background Colors
    var backgroundColor: Color { get }
    var backgroundColorSecondary: Color { get }
    var backgroundColorTertiary: Color { get }
    var surfaceColor: Color { get }
    var cardColor: Color { get }
    
    // MARK: - Text Colors
    var textColorPrimary: Color { get }
    var textColorSecondary: Color { get }
    var textColorTertiary: Color { get }
    var textColorInverse: Color { get }
    var textColorDisabled: Color { get }
    
    // MARK: - Border & Divider Colors
    var borderColor: Color { get }
    var dividerColor: Color { get }
    var focusColor: Color { get }
    
    // MARK: - Status Colors
    var successColor: Color { get }
    var warningColor: Color { get }
    var errorColor: Color { get }
    var infoColor: Color { get }
    
    // MARK: - Financial-specific Colors
    var incomeColor: Color { get }
    var expenseColor: Color { get }
    var transferColor: Color { get }
    var investmentGainColor: Color { get }
    var investmentLossColor: Color { get }
    
    // MARK: - Interactive Colors
    var buttonBackgroundColor: Color { get }
    var buttonTextColor: Color { get }
    var buttonBackgroundColorPressed: Color { get }
    var buttonBackgroundColorDisabled: Color { get }
    
    // MARK: - Shadow Colors
    var shadowColor: Color { get }
    var overlayColor: Color { get }
}

// MARK: - Light Theme Implementation
public struct LightTheme: Theme {
    public let name = "Light"
    public let colorScheme: ColorScheme = .light
    
    // MARK: - Primary Colors
    public let primaryColor = DesignTokens.Colors.primary500
    public let primaryColorVariant = DesignTokens.Colors.primary700
    public let secondaryColor = DesignTokens.Colors.secondary500
    public let secondaryColorVariant = DesignTokens.Colors.secondary700
    
    // MARK: - Background Colors
    public let backgroundColor = DesignTokens.Colors.neutral0
    public let backgroundColorSecondary = DesignTokens.Colors.neutral50
    public let backgroundColorTertiary = DesignTokens.Colors.neutral100
    public let surfaceColor = DesignTokens.Colors.neutral0
    public let cardColor = DesignTokens.Colors.neutral0
    
    // MARK: - Text Colors
    public let textColorPrimary = DesignTokens.Colors.neutral900
    public let textColorSecondary = DesignTokens.Colors.neutral700
    public let textColorTertiary = DesignTokens.Colors.neutral500
    public let textColorInverse = DesignTokens.Colors.neutral0
    public let textColorDisabled = DesignTokens.Colors.neutral400
    
    // MARK: - Border & Divider Colors
    public let borderColor = DesignTokens.Colors.neutral300
    public let dividerColor = DesignTokens.Colors.neutral200
    public let focusColor = DesignTokens.Colors.primary500
    
    // MARK: - Status Colors
    public let successColor = DesignTokens.Colors.secondary500
    public let warningColor = DesignTokens.Colors.tertiary500
    public let errorColor = DesignTokens.Colors.error500
    public let infoColor = DesignTokens.Colors.primary500
    
    // MARK: - Financial-specific Colors
    public let incomeColor = DesignTokens.Colors.secondary500   // Green for income
    public let expenseColor = DesignTokens.Colors.error500     // Red for expenses
    public let transferColor = DesignTokens.Colors.primary500  // Blue for transfers
    public let investmentGainColor = DesignTokens.Colors.secondary600  // Darker green for gains
    public let investmentLossColor = DesignTokens.Colors.error600      // Darker red for losses
    
    // MARK: - Interactive Colors
    public let buttonBackgroundColor = DesignTokens.Colors.primary500
    public let buttonTextColor = DesignTokens.Colors.neutral0
    public let buttonBackgroundColorPressed = DesignTokens.Colors.primary700
    public let buttonBackgroundColorDisabled = DesignTokens.Colors.neutral300
    
    // MARK: - Shadow Colors
    public let shadowColor = DesignTokens.Colors.neutral900.opacity(0.1)
    public let overlayColor = DesignTokens.Colors.neutral900.opacity(0.6)
}

// MARK: - Dark Theme Implementation
public struct DarkTheme: Theme {
    public let name = "Dark"
    public let colorScheme: ColorScheme = .dark
    
    // MARK: - Primary Colors
    public let primaryColor = DesignTokens.Colors.primary400
    public let primaryColorVariant = DesignTokens.Colors.primary300
    public let secondaryColor = DesignTokens.Colors.secondary400
    public let secondaryColorVariant = DesignTokens.Colors.secondary300
    
    // MARK: - Background Colors
    public let backgroundColor = DesignTokens.Colors.neutral900
    public let backgroundColorSecondary = DesignTokens.Colors.neutral800
    public let backgroundColorTertiary = DesignTokens.Colors.neutral700
    public let surfaceColor = DesignTokens.Colors.neutral800
    public let cardColor = DesignTokens.Colors.neutral800
    
    // MARK: - Text Colors
    public let textColorPrimary = DesignTokens.Colors.neutral50
    public let textColorSecondary = DesignTokens.Colors.neutral200
    public let textColorTertiary = DesignTokens.Colors.neutral400
    public let textColorInverse = DesignTokens.Colors.neutral900
    public let textColorDisabled = DesignTokens.Colors.neutral500
    
    // MARK: - Border & Divider Colors
    public let borderColor = DesignTokens.Colors.neutral600
    public let dividerColor = DesignTokens.Colors.neutral700
    public let focusColor = DesignTokens.Colors.primary400
    
    // MARK: - Status Colors
    public let successColor = DesignTokens.Colors.secondary400
    public let warningColor = DesignTokens.Colors.tertiary400
    public let errorColor = DesignTokens.Colors.error400
    public let infoColor = DesignTokens.Colors.primary400
    
    // MARK: - Financial-specific Colors
    public let incomeColor = DesignTokens.Colors.secondary400
    public let expenseColor = DesignTokens.Colors.error400
    public let transferColor = DesignTokens.Colors.primary400
    public let investmentGainColor = DesignTokens.Colors.secondary300
    public let investmentLossColor = DesignTokens.Colors.error300
    
    // MARK: - Interactive Colors
    public let buttonBackgroundColor = DesignTokens.Colors.primary500
    public let buttonTextColor = DesignTokens.Colors.neutral0
    public let buttonBackgroundColorPressed = DesignTokens.Colors.primary400
    public let buttonBackgroundColorDisabled = DesignTokens.Colors.neutral600
    
    // MARK: - Shadow Colors
    public let shadowColor = DesignTokens.Colors.neutral1000.opacity(0.3)
    public let overlayColor = DesignTokens.Colors.neutral1000.opacity(0.8)
}

// MARK: - High Contrast Theme (Accessibility)
public struct HighContrastTheme: Theme {
    public let name = "High Contrast"
    public let colorScheme: ColorScheme = .light
    
    // MARK: - Primary Colors (Higher contrast ratios)
    public let primaryColor = DesignTokens.Colors.primary800
    public let primaryColorVariant = DesignTokens.Colors.primary900
    public let secondaryColor = DesignTokens.Colors.secondary800
    public let secondaryColorVariant = DesignTokens.Colors.secondary900
    
    // MARK: - Background Colors
    public let backgroundColor = DesignTokens.Colors.neutral0
    public let backgroundColorSecondary = DesignTokens.Colors.neutral0
    public let backgroundColorTertiary = DesignTokens.Colors.neutral50
    public let surfaceColor = DesignTokens.Colors.neutral0
    public let cardColor = DesignTokens.Colors.neutral0
    
    // MARK: - Text Colors (Maximum contrast)
    public let textColorPrimary = DesignTokens.Colors.neutral1000
    public let textColorSecondary = DesignTokens.Colors.neutral900
    public let textColorTertiary = DesignTokens.Colors.neutral800
    public let textColorInverse = DesignTokens.Colors.neutral0
    public let textColorDisabled = DesignTokens.Colors.neutral600
    
    // MARK: - Border & Divider Colors (High contrast)
    public let borderColor = DesignTokens.Colors.neutral800
    public let dividerColor = DesignTokens.Colors.neutral700
    public let focusColor = DesignTokens.Colors.primary800
    
    // MARK: - Status Colors (High contrast)
    public let successColor = DesignTokens.Colors.secondary800
    public let warningColor = DesignTokens.Colors.tertiary800
    public let errorColor = DesignTokens.Colors.error800
    public let infoColor = DesignTokens.Colors.primary800
    
    // MARK: - Financial-specific Colors (High contrast)
    public let incomeColor = DesignTokens.Colors.secondary800
    public let expenseColor = DesignTokens.Colors.error800
    public let transferColor = DesignTokens.Colors.primary800
    public let investmentGainColor = DesignTokens.Colors.secondary900
    public let investmentLossColor = DesignTokens.Colors.error900
    
    // MARK: - Interactive Colors
    public let buttonBackgroundColor = DesignTokens.Colors.primary800
    public let buttonTextColor = DesignTokens.Colors.neutral0
    public let buttonBackgroundColorPressed = DesignTokens.Colors.primary900
    public let buttonBackgroundColorDisabled = DesignTokens.Colors.neutral400
    
    // MARK: - Shadow Colors
    public let shadowColor = DesignTokens.Colors.neutral1000.opacity(0.2)
    public let overlayColor = DesignTokens.Colors.neutral1000.opacity(0.8)
}

// MARK: - Theme Manager
public class ThemeManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentTheme: Theme
    @Published public var isDarkMode: Bool = false
    @Published public var isHighContrastEnabled: Bool = false
    @Published public var isReducedMotionEnabled: Bool = false
    @Published public var dynamicTypeSize: DynamicTypeSize = .large
    
    // MARK: - Available Themes
    public let lightTheme = LightTheme()
    public let darkTheme = DarkTheme()
    public let highContrastTheme = HighContrastTheme()
    
    // MARK: - User Defaults Keys
    private let themePreferenceKey = "com.moneymanager.theme.preference"
    private let highContrastKey = "com.moneymanager.accessibility.highcontrast"
    private let reducedMotionKey = "com.moneymanager.accessibility.reducedmotion"
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    public var preferredColorScheme: ColorScheme? {
        if isHighContrastEnabled {
            return .light  // High contrast is always light mode
        }
        return isDarkMode ? .dark : .light
    }
    
    // MARK: - Initialization
    public init() {
        // Start with light theme as default
        self.currentTheme = lightTheme
        
        // Load user preferences
        loadUserPreferences()
        
        // Apply initial theme
        updateTheme()
        
        // Set up observers for system changes
        setupSystemObservers()
    }
    
    // MARK: - Theme Management
    public func toggleDarkMode() {
        isDarkMode.toggle()
        updateTheme()
        saveUserPreferences()
    }
    
    public func setDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
        updateTheme()
        saveUserPreferences()
    }
    
    public func toggleHighContrast() {
        isHighContrastEnabled.toggle()
        updateTheme()
        saveUserPreferences()
    }
    
    public func setHighContrast(_ enabled: Bool) {
        isHighContrastEnabled = enabled
        updateTheme()
        saveUserPreferences()
    }
    
    public func setReducedMotion(_ enabled: Bool) {
        isReducedMotionEnabled = enabled
        saveUserPreferences()
    }
    
    public func setDynamicTypeSize(_ size: DynamicTypeSize) {
        dynamicTypeSize = size
        saveUserPreferences()
    }
    
    private func updateTheme() {
        DispatchQueue.main.async {
            if self.isHighContrastEnabled {
                self.currentTheme = self.highContrastTheme
            } else if self.isDarkMode {
                self.currentTheme = self.darkTheme
            } else {
                self.currentTheme = self.lightTheme
            }
        }
    }
    
    // MARK: - User Preferences
    public func loadUserPreferences() {
        let userDefaults = UserDefaults.standard
        
        // Load theme preference
        if let themePreference = userDefaults.object(forKey: themePreferenceKey) as? String {
            switch themePreference {
            case "dark":
                isDarkMode = true
            case "light":
                isDarkMode = false
            default:
                #if canImport(UIKit)
                isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
                #elseif canImport(AppKit)
                // On macOS, approximate via effectiveAppearance
                isDarkMode = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                #else
                isDarkMode = false
                #endif
            }
        }
        
        // Load accessibility preferences
        isHighContrastEnabled = userDefaults.bool(forKey: highContrastKey)
        isReducedMotionEnabled = userDefaults.bool(forKey: reducedMotionKey)
        
        updateTheme()
    }
    
    private func saveUserPreferences() {
        let userDefaults = UserDefaults.standard
        
        // Save theme preference
        let themePreference = isDarkMode ? "dark" : "light"
        userDefaults.set(themePreference, forKey: themePreferenceKey)
        
        // Save accessibility preferences
        userDefaults.set(isHighContrastEnabled, forKey: highContrastKey)
        userDefaults.set(isReducedMotionEnabled, forKey: reducedMotionKey)
        
        userDefaults.synchronize()
    }
    
    // MARK: - System Observers
    private func setupSystemObservers() {
        #if canImport(UIKit)
        // Observe system dark mode changes (iOS)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.syncWithSystemSettings()
            }
            .store(in: &cancellables)
        
        // Observe accessibility changes (iOS)
        NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isReducedMotionEnabled = UIAccessibility.isReduceMotionEnabled
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIAccessibility.darkerSystemColorsStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isHighContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
                self?.updateTheme()
            }
            .store(in: &cancellables)
        #elseif canImport(AppKit)
        // Observe app activation on macOS
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.syncWithSystemSettings()
            }
            .store(in: &cancellables)
        #endif
    }
    
    private func syncWithSystemSettings() {
        #if canImport(UIKit)
        // Sync with system accessibility settings (iOS)
        let systemHasHighContrast = UIAccessibility.isDarkerSystemColorsEnabled
        let systemHasReducedMotion = UIAccessibility.isReduceMotionEnabled
        
        if systemHasHighContrast != isHighContrastEnabled {
            isHighContrastEnabled = systemHasHighContrast
            updateTheme()
        }
        
        if systemHasReducedMotion != isReducedMotionEnabled {
            isReducedMotionEnabled = systemHasReducedMotion
        }
        #elseif canImport(AppKit)
        // On macOS, approximate dark mode only
        let dark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if dark != isDarkMode {
            isDarkMode = dark
            updateTheme()
        }
        #endif
    }
    
    // MARK: - Platform-Specific Adaptations
    public func configureForPlatform() {
        #if os(watchOS)
        configurewatchOSTheme()
        #elseif os(tvOS)
        configuretvOSTheme()
        #elseif os(macOS)
        configuremacOSTheme()
        #elseif os(visionOS)
        configurevisionOSTheme()
        #endif
    }
    
    #if os(watchOS)
    private func configurewatchOSTheme() {
        // Adjust for smaller screen and limited colors
        // Use higher contrast ratios for better visibility
    }
    #endif
    
    #if os(tvOS)
    private func configuretvOSTheme() {
        // Adjust for living room viewing distances
        // Use focus-appropriate colors and contrasts
    }
    #endif
    
    #if os(macOS)
    private func configuremacOSTheme() {
        // Adapt for desktop environment
        // Consider window chrome and menu bar integration
    }
    #endif
    
    #if os(visionOS)
    private func configurevisionOSTheme() {
        // Adapt for immersive and mixed reality contexts
        // Use appropriate transparency and depth cues
    }
    #endif
}

// MARK: - SwiftUI Environment Key
public struct ThemeKey: EnvironmentKey {
    public static let defaultValue: Theme = LightTheme()
}

extension EnvironmentValues {
    public var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - SwiftUI View Extensions
extension View {
    public func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
    
    public func themeBackground() -> some View {
        #if canImport(UIKit)
        return self.background(Color(.systemBackground))
        #elseif canImport(AppKit)
        return self.background(Color(NSColor.windowBackgroundColor))
        #else
        return self
        #endif
    }
    
    public func themeForeground() -> some View {
        #if canImport(UIKit)
        return self.foregroundColor(Color(.label))
        #elseif canImport(AppKit)
        return self.foregroundColor(Color(NSColor.labelColor))
        #else
        return self
        #endif
    }
}

#if DEBUG
// MARK: - Theme Preview
struct ThemeSystem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light theme preview
            ThemePreviewView()
                .environment(\.theme, LightTheme())
                .previewDisplayName("Light Theme")
            
            // Dark theme preview
            ThemePreviewView()
                .environment(\.theme, DarkTheme())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Theme")
            
            // High contrast preview
            ThemePreviewView()
                .environment(\.theme, HighContrastTheme())
                .previewDisplayName("High Contrast Theme")
        }
    }
}

struct ThemePreviewView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                
                // Colors Preview
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Theme Colors")
                        .font(.headline)
                        .foregroundColor(theme.textColorPrimary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: DesignTokens.Spacing.sm) {
                        colorSwatch("Primary", theme.primaryColor)
                        colorSwatch("Secondary", theme.secondaryColor)
                        colorSwatch("Success", theme.successColor)
                        colorSwatch("Error", theme.errorColor)
                        colorSwatch("Income", theme.incomeColor)
                        colorSwatch("Expense", theme.expenseColor)
                        colorSwatch("Transfer", theme.transferColor)
                        colorSwatch("Background", theme.backgroundColor)
                    }
                }
                
                // Interactive Elements Preview
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Interactive Elements")
                        .font(.headline)
                        .foregroundColor(theme.textColorPrimary)
                    
                    HStack {
                        Button("Primary Button") {}
                            .padding()
                            .background(theme.buttonBackgroundColor)
                            .foregroundColor(theme.buttonTextColor)
                            .cornerRadius(DesignTokens.BorderRadius.button)
                        
                        Button("Secondary Button") {}
                            .padding()
                            .background(theme.backgroundColor)
                            .foregroundColor(theme.primaryColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.button)
                                    .stroke(theme.primaryColor, lineWidth: DesignTokens.BorderWidth.thin)
                            )
                    }
                }
            }
            .padding()
        }
        .background(theme.backgroundColor)
    }
    
    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
                .fill(color)
                .frame(height: 50)
            Text(name)
                .font(.caption)
                .foregroundColor(theme.textColorSecondary)
        }
    }
}
#endif

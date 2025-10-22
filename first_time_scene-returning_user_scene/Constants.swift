//
//  Constants.swift
//  MyApp
//
//  App-wide constants and configuration values

import Foundation
import SwiftUI

// MARK: - App Constants
enum AppConstants {

    // MARK: - App Info
    enum App {
        static let name = "MyApp"
        static let bundleId = "com.example.myapp"
        static let version = "1.0.0"
        static let buildNumber = "1"
    }

    // MARK: - API Configuration
    enum API {
        #if DEBUG
        static let baseURL = "https://api-dev.example.com"
        #else
        static let baseURL = "https://api.example.com"
        #endif

        static let timeout: TimeInterval = 30
        static let maxRetries = 3
    }

    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let colorScheme = "colorScheme"
        static let notificationsEnabled = "notificationsEnabled"
        static let dailyReminders = "dailyReminders"
        static let achievementAlerts = "achievementAlerts"
        static let lastSyncDate = "lastSyncDate"
    }

    // MARK: - Layout Constants
    enum Layout {
        // Spacing
        static let spacingXS: CGFloat = 4
        static let spacingS: CGFloat = 8
        static let spacingM: CGFloat = 16
        static let spacingL: CGFloat = 24
        static let spacingXL: CGFloat = 32

        // Margins (HIG guidelines)
        static let marginHorizontal: CGFloat = 20
        static let marginVertical: CGFloat = 16

        // Corner Radius
        static let cornerRadiusS: CGFloat = 8
        static let cornerRadiusM: CGFloat = 12
        static let cornerRadiusL: CGFloat = 16
        static let cornerRadiusXL: CGFloat = 24

        // Touch Targets (HIG minimum 44pt)
        static let minTouchTarget: CGFloat = 44

        // Navigation
        static let navBarHeight: CGFloat = 44
        static let largeNavBarHeight: CGFloat = 96
        static let tabBarHeight: CGFloat = 49
        static let tabBarHeightWithHomeIndicator: CGFloat = 83
    }

    // MARK: - Animation Durations
    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
    }

    // MARK: - Typography
    enum Typography {
        // Font Sizes (in points)
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption1: CGFloat = 12
        static let caption2: CGFloat = 11
    }

    // MARK: - Accessibility
    enum Accessibility {
        // Contrast Ratios (WCAG 2.1)
        static let minimumContrast: Double = 4.5 // AA for normal text
        static let largeTextContrast: Double = 3.0 // AA for large text
        static let enhancedContrast: Double = 7.0 // AAA for normal text
    }

    // MARK: - Feature Flags
    enum FeatureFlags {
        static let enableAnalytics = true
        static let enablePushNotifications = true
        static let enableBiometricAuth = true
        static let showDebugMenu = false
    }

    // MARK: - External URLs
    enum URLs {
        static let termsOfService = URL(string: "https://example.com/terms")!
        static let privacyPolicy = URL(string: "https://example.com/privacy")!
        static let support = URL(string: "https://example.com/support")!
        static let website = URL(string: "https://example.com")!
    }
}

// MARK: - Environment Helper
enum AppEnvironment {
    case development
    case staging
    case production

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var name: String {
        switch self {
        case .development: return "Development"
        case .staging: return "Staging"
        case .production: return "Production"
        }
    }
}

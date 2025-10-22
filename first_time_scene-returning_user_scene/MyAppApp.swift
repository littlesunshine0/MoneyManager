//
//  MyAppApp.swift
//  MyApp
//
//  Created on October 18, 2025.
//  Main application entry point

import SwiftUI
import Combine

@main
struct MyAppApp: App {
    // App delegate adapter for handling legacy lifecycle events
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // App-wide state management
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authManager = SystemAuthenticationManager()
    @StateObject private var accessibilityManager = AccessibilitySystem.AccessibilityManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeManager)
                .environmentObject(authManager)
                .environmentObject(accessibilityManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
    }
}

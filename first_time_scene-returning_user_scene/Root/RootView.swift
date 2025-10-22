//
//  RootView.swift
//  MyApp
//
//  Root coordinator determining first-time vs returning user flow

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authManager: SystemAuthenticationManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager

    var body: some View {
        Group {
            if authManager.isOnboardingComplete == false {
                // First-time user: run the integrated onboarding flow
                OnboardingFlowView(
                    authManager: authManager,
                    themeManager: themeManager,
                    accessibilityManager: accessibilityManager
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                // Post-onboarding authentication and main app
                switch authManager.authenticationState {
                case .needsSetup:
                    SystemPasscodeSetupView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .needsPasscode:
                    SystemPasscodeEntryView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                case .needsBiometric:
                    SystemBiometricAuthenticationView()
                        .transition(.scale(scale: 0.96).combined(with: .opacity))

                case .authenticated:
                    MainTabBarView()
                        .transition(.opacity)

                case .unauthenticated:
                    // Fallback if state isn’t resolved yet
                    SystemPasscodeEntryView()
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isOnboardingComplete)
        .animation(.easeInOut(duration: 0.3), value: authManager.authenticationState.description)
    }
}

// MARK: - Preview
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // First-time user
            RootView()
                .environmentObject(ThemeManager())
                .environmentObject({
                    let m = SystemAuthenticationManager()
                    m.logout()
                    return m
                }())
                .environmentObject(AccessibilitySystem.AccessibilityManager())
                .previewDisplayName("First Time User")

            // Returning user (authenticated)
            RootView()
                .environmentObject(ThemeManager())
                .environmentObject({
                    let m = SystemAuthenticationManager()
                    m.completeOnboarding()
                    Task { @MainActor in
                        await m.authenticateWithPasscode("1234")
                    }
                    return m
                }())
                .environmentObject(AccessibilitySystem.AccessibilityManager())
                .previewDisplayName("Authenticated")
        }
    }
}

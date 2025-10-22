//
//  SettingsViewModel.swift
//  MyApp
//
//  Settings state and preference management

import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedAppearance: Int = 0 // 0: System, 1: Light, 2: Dark
    @Published var notificationsEnabled: Bool = true
    @Published var dailyReminders: Bool = true
    @Published var achievementAlerts: Bool = true
    @Published var reduceMotion: Bool = false
    @Published var increaseContrast: Bool = false

    let appVersion = "1.0.0"

    var textSizeLabel: String {
        "Default"
    }

    init() {
        loadSettings()
    }

    func loadSettings() {
        // Load from UserDefaults
        selectedAppearance = UserDefaults.standard.integer(forKey: "appearance")
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        dailyReminders = UserDefaults.standard.bool(forKey: "dailyReminders")
        achievementAlerts = UserDefaults.standard.bool(forKey: "achievementAlerts")
    }

    func saveSettings() {
        UserDefaults.standard.set(selectedAppearance, forKey: "appearance")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(dailyReminders, forKey: "dailyReminders")
        UserDefaults.standard.set(achievementAlerts, forKey: "achievementAlerts")
    }

    func exportData() {
        // Export user data
        print("📤 Exporting data...")
    }

    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }

    func openTerms() {
        if let url = URL(string: "https://example.com/terms") {
            UIApplication.shared.open(url)
        }
    }

    func openPrivacy() {
        if let url = URL(string: "https://example.com/privacy") {
            UIApplication.shared.open(url)
        }
    }

    func signOut() {
        // Sign out logic
        print("👋 Signing out...")
    }
}

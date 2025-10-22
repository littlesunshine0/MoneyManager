//
//  SettingsView.swift
//  MyApp
//
//  App settings and preferences with accessibility options

import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                // Appearance Section
                Section {
                    Picker("Appearance", selection: $viewModel.selectedAppearance) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    .onChange(of: viewModel.selectedAppearance) { _, newValue in
                        updateAppearance(newValue)
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose how the app looks on your device")
                }

                // Notifications Section
                Section {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                        .tint(AppColors.accent)

                    if viewModel.notificationsEnabled {
                        Toggle("Daily Reminders", isOn: $viewModel.dailyReminders)
                            .tint(AppColors.accent)

                        Toggle("Achievement Alerts", isOn: $viewModel.achievementAlerts)
                            .tint(AppColors.accent)
                    }
                } header: {
                    Text("Notifications")
                }

                // Accessibility Section
                Section {
                    Toggle("Reduce Motion", isOn: $viewModel.reduceMotion)
                        .tint(AppColors.accent)

                    Toggle("Increase Contrast", isOn: $viewModel.increaseContrast)
                        .tint(AppColors.accent)

                    HStack {
                        Text("Text Size")
                        Spacer()
                        Text(viewModel.textSizeLabel)
                            .foregroundColor(AppColors.textSecondary)
                    }
                } header: {
                    Text("Accessibility")
                } footer: {
                    Text("Adjust settings for easier use. System settings override these options.")
                }

                // Data & Privacy Section
                Section {
                    Button("Export Data") {
                        viewModel.exportData()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }

                    Button("Reset Onboarding") {
                        viewModel.resetOnboarding()
                        appState.hasCompletedOnboarding = false
                        dismiss()
                    }
                    .foregroundColor(AppColors.warning)
                } header: {
                    Text("Data & Privacy")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Button("Terms of Service") {
                        viewModel.openTerms()
                    }

                    Button("Privacy Policy") {
                        viewModel.openPrivacy()
                    }
                } header: {
                    Text("About")
                }

                // Danger Zone
                Section {
                    Button("Sign Out") {
                        viewModel.signOut()
                    }
                    .foregroundColor(AppColors.error)
                } header: {
                    Text("Account")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
    }

    private func updateAppearance(_ value: Int) {
        switch value {
        case 1:
            appState.setColorScheme(.light)
        case 2:
            appState.setColorScheme(.dark)
        default:
            appState.setColorScheme(nil)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppStateManager())
    }
}

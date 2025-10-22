//
//  StateRepository.swift
//  MyApp
//
//  App state persistence and restoration

import Foundation

// MARK: - App State Model
struct AppState: Codable {
    var hasCompletedOnboarding: Bool
    var selectedTabIndex: Int
    var lastViewedScreen: String?
    var navigationPath: [String]
    var lastSyncDate: Date?

    init(
        hasCompletedOnboarding: Bool = false,
        selectedTabIndex: Int = 0,
        lastViewedScreen: String? = nil,
        navigationPath: [String] = [],
        lastSyncDate: Date? = nil
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.selectedTabIndex = selectedTabIndex
        self.lastViewedScreen = lastViewedScreen
        self.navigationPath = navigationPath
        self.lastSyncDate = lastSyncDate
    }
}

// MARK: - State Repository Protocol
protocol StateRepositoryProtocol {
    func loadState() -> AppState
    func saveState(_ state: AppState)
    func clearState()
    func hasCompletedOnboarding() -> Bool
    func setOnboardingCompleted(_ completed: Bool)
}

// MARK: - State Repository Implementation
class StateRepository: StateRepositoryProtocol {

    private let userDefaults: UserDefaults
    private let stateKey = "appState"
    private let onboardingKey = AppConstants.UserDefaultsKeys.hasCompletedOnboarding

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadState() -> AppState {
        guard let data = userDefaults.data(forKey: stateKey) else {
            return AppState()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let state = try? decoder.decode(AppState.self, from: data) else {
            return AppState()
        }

        return state
    }

    func saveState(_ state: AppState) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(state) else {
            print("❌ Failed to encode app state")
            return
        }

        userDefaults.set(data, forKey: stateKey)
    }

    func clearState() {
        userDefaults.removeObject(forKey: stateKey)
    }

    func hasCompletedOnboarding() -> Bool {
        userDefaults.bool(forKey: onboardingKey)
    }

    func setOnboardingCompleted(_ completed: Bool) {
        userDefaults.set(completed, forKey: onboardingKey)
    }
}

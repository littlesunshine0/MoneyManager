//
//  ProfileViewModel.swift
//  MyApp
//
//  Profile state and user data management

import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userName: String = "John Doe"
    @Published var userEmail: String = "john.doe@example.com"
    @Published var totalGoals: Int = 12
    @Published var currentStreak: Int = 7
    @Published var totalPoints: Int = 2845

    func loadUserData() async {
        // Load user data from repository
        // This would typically fetch from UserDefaults, CoreData, or API
    }

    func updateProfile(name: String, email: String) {
        userName = name
        userEmail = email
        // Save to repository
    }
}

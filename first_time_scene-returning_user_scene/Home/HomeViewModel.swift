//
//  HomeViewModel.swift
//  MyApp
//
//  Home screen state management and business logic

import SwiftUI
import Combine

// MARK: - Activity Item Model
struct ActivityItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let timeAgo: String
    let color: Color
}

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var activeGoals: Int = 0
    @Published var completedToday: Int = 0
    @Published var recentItems: [ActivityItem] = []
    @Published var isLoading: Bool = false

    // MARK: - Data Loading
    func loadData() async {
        isLoading = true

        // Simulate API call
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Mock data
        activeGoals = 5
        completedToday = 3

        recentItems = [
            ActivityItem(
                icon: "checkmark.circle.fill",
                title: "Morning Workout",
                description: "Completed 30 min cardio session",
                timeAgo: "2h ago",
                color: AppColors.success
            ),
            ActivityItem(
                icon: "book.fill",
                title: "Reading Goal",
                description: "Finished chapter 5 of current book",
                timeAgo: "5h ago",
                color: AppColors.accent
            ),
            ActivityItem(
                icon: "drop.fill",
                title: "Hydration",
                description: "Reached daily water intake goal",
                timeAgo: "6h ago",
                color: .blue
            ),
            ActivityItem(
                icon: "moon.zzz.fill",
                title: "Sleep Tracking",
                description: "8 hours of quality sleep logged",
                timeAgo: "12h ago",
                color: .purple
            )
        ]

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }
}

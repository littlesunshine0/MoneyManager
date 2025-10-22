//
//  OnboardingViewModel.swift
//  MyApp
//
//  Manages onboarding flow state and navigation

import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var isCompleted: Bool = false

    private let totalPages = 5 // Welcome + 3 Features + Permissions

    // MARK: - Navigation
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }

    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }

    func skip() {
        completeOnboarding()
    }

    func completeOnboarding() {
        isCompleted = true
    }

    // MARK: - Progress
    var progress: Double {
        Double(currentPage + 1) / Double(totalPages)
    }

    var isFirstPage: Bool {
        currentPage == 0
    }

    var isLastPage: Bool {
        currentPage == totalPages - 1
    }
}

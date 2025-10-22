//
//  OnboardingContainerView.swift
//  MyApp
//
//  Container managing onboarding flow with page navigation

import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.accent.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView(selection: $viewModel.currentPage) {
                // Welcome Screen
                WelcomeView(viewModel: viewModel)
                    .tag(0)

                // Feature Highlights (3 screens)
                FeatureHighlightView(
                    icon: "star.fill",
                    title: "Track Your Goals",
                    description: "Set and achieve your personal goals with intelligent tracking and reminders.",
                    pageNumber: 1,
                    viewModel: viewModel
                )
                .tag(1)

                FeatureHighlightView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Visualize Progress",
                    description: "Beautiful charts and insights help you understand your journey.",
                    pageNumber: 2,
                    viewModel: viewModel
                )
                .tag(2)

                FeatureHighlightView(
                    icon: "bell.badge.fill",
                    title: "Stay Motivated",
                    description: "Smart notifications keep you on track without being overwhelming.",
                    pageNumber: 3,
                    viewModel: viewModel
                )
                .tag(3)

                // Permission Request
                PermissionsView(viewModel: viewModel)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                // Haptic feedback on completion
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                // Mark onboarding as complete
                appState.completeOnboarding()
            }
        }
    }
}

// MARK: - Preview
struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView()
            .environmentObject(AppStateManager())
    }
}

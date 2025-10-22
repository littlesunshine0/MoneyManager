//
//  WelcomeView.swift
//  MyApp
//
//  First onboarding screen - app value proposition

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App Icon/Logo
            Image(systemName: "app.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(AppColors.accent)
                .accessibilityLabel("App Logo")

            // Headline
            Text("Welcome to MyApp")
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            // Value Statement
            Text("Achieve your goals with intelligent tracking, beautiful insights, and motivating reminders.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Continue Button
            Button {
                withAnimation {
                    viewModel.nextPage()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.accent)
                    .cornerRadius(12)
            }
            .accessibilityLabel("Get Started")
            .accessibilityHint("Continue to feature highlights")
            .padding(.horizontal, 40)

            // Skip Button
            Button {
                viewModel.skip()
                UISelectionFeedbackGenerator().selectionChanged()
            } label: {
                Text("Skip")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.bottom, 40)
            .accessibilityLabel("Skip onboarding")
        }
        .padding()
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView(viewModel: OnboardingViewModel())
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")

            WelcomeView(viewModel: OnboardingViewModel())
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

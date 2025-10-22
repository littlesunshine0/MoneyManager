//
//  FeatureHighlightView.swift
//  MyApp
//
//  Onboarding carousel screens showing key features

import SwiftUI

struct FeatureHighlightView: View {
    let icon: String
    let title: String
    let description: String
    let pageNumber: Int
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Feature Icon
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.accent, AppColors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityLabel(title)

            VStack(spacing: 16) {
                // Feature Title
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                // Feature Description
                Text(description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Navigation Buttons
            VStack(spacing: 16) {
                Button {
                    withAnimation {
                        viewModel.nextPage()
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(pageNumber == 3 ? "Continue" : "Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.accent)
                        .cornerRadius(12)
                }
                .accessibilityLabel(pageNumber == 3 ? "Continue to permissions" : "Next feature")
                .padding(.horizontal, 40)

                Button {
                    viewModel.skip()
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
                .accessibilityLabel("Skip remaining features")
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - Preview
struct FeatureHighlightView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureHighlightView(
            icon: "star.fill",
            title: "Track Your Goals",
            description: "Set and achieve your personal goals with intelligent tracking.",
            pageNumber: 1,
            viewModel: OnboardingViewModel()
        )
    }
}

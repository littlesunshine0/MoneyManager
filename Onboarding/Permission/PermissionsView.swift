//
//  PermissionsView.swift
//  MyApp
//
//  Permission priming screen explaining value before system prompt

import SwiftUI
import UserNotifications

struct PermissionsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Permission Icon
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: 120, height: 120)

                CustomIconView(.bell, size: 60, color: AppColors.accent)
            }
            .accessibilityLabel("Notifications icon")

            VStack(spacing: 16) {
                // Permission Title
                Text("Stay on Track")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                // Permission Explanation (benefit-focused)
                Text("Get helpful reminders at the perfect time to keep you motivated and on schedule.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Permission benefits list
            VStack(alignment: .leading, spacing: 16) {
                PermissionBenefitRow(
                    icon: "clock.fill",
                    text: "Smart timing based on your schedule"
                )
                PermissionBenefitRow(
                    icon: "moon.zzz.fill",
                    text: "Respects your quiet hours"
                )
                PermissionBenefitRow(
                    icon: "slider.horizontal.3",
                    text: "Fully customizable frequency"
                )
            }
            .padding(.horizontal, 40)

            Spacer()

            // Action Buttons
            VStack(spacing: 16) {
                // Enable Button
                Button {
                    requestNotificationPermission()
                } label: {
                    Text("Enable Notifications")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.accent)
                        .cornerRadius(12)
                }
                .accessibilityLabel("Enable notifications")
                .accessibilityHint("Opens system permission dialog")
                .padding(.horizontal, 40)

                // Maybe Later Button
                Button {
                    completeOnboarding()
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    Text("Maybe Later")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
                .accessibilityLabel("Skip notifications")
                .accessibilityHint("You can enable this later in Settings")
            }
            .padding(.bottom, 40)
        }
        .padding()
        .task {
            await checkNotificationStatus()
        }
    }

    // MARK: - Permission Request
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                completeOnboarding()
            }
        }
    }

    private func completeOnboarding() {
        withAnimation {
            viewModel.completeOnboarding()
        }
    }

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        DispatchQueue.main.async {
            self.notificationStatus = settings.authorizationStatus

            // If already authorized, auto-complete
            if settings.authorizationStatus == .authorized {
                completeOnboarding()
            }
        }
    }
}

// MARK: - Permission Benefit Row
struct PermissionBenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.accent)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppColors.textSecondary)

            Spacer()
        }
    }
}

// MARK: - Preview
struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView(viewModel: OnboardingViewModel())
    }
}

//
//  ProfileView.swift
//  MyApp
//
//  User profile display and management

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.accent, AppColors.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            CustomIconView(.profile, size: 50, color: .white)
                        )
                        .accessibilityLabel("Profile picture")

                    // Name
                    Text(viewModel.userName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    // Email
                    Text(viewModel.userEmail)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                // Stats Grid
                HStack(spacing: 16) {
                    ProfileStatBox(title: "Goals", value: "\(viewModel.totalGoals)")
                    ProfileStatBox(title: "Streak", value: "\(viewModel.currentStreak)d")
                    ProfileStatBox(title: "Points", value: "\(viewModel.totalPoints)")
                }
                .padding(.horizontal, 20)

                // Menu Items
                VStack(spacing: 0) {
                    ProfileMenuItem(
                        icon: "person.crop.circle",
                        title: "Edit Profile",
                        showChevron: true
                    ) {
                        // Edit profile action
                    }

                    Divider()
                        .padding(.leading, 60)

                    ProfileMenuItem(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Statistics",
                        showChevron: true
                    ) {
                        // Statistics action
                    }

                    Divider()
                        .padding(.leading, 60)

                    ProfileMenuItem(
                        icon: "heart.fill",
                        title: "Favorites",
                        showChevron: true
                    ) {
                        // Favorites action
                    }

                    Divider()
                        .padding(.leading, 60)

                    ProfileMenuItem(
                        icon: "bell.badge.fill",
                        title: "Notifications",
                        showChevron: true
                    ) {
                        // Notifications action
                    }
                }
                .background(AppColors.backgroundSecondary)
                .cornerRadius(12)
                .padding(.horizontal, 20)

                // Settings Button
                Button {
                    showingSettings = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .accessibilityLabel("Open settings")

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(AppColors.backgroundPrimary)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Profile Stat Box
struct ProfileStatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let showChevron: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.accent)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
    }
}

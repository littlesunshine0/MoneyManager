//
//  HomeView.swift
//  MyApp
//
//  Main home screen with primary content

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    Text("Here's what's happening today")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Stats Cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Active Goals",
                        value: "\(viewModel.activeGoals)",
                        icon: "target",
                        color: AppColors.accent
                    )

                    StatCard(
                        title: "Completed",
                        value: "\(viewModel.completedToday)",
                        icon: "checkmark.circle.fill",
                        color: AppColors.success
                    )
                }
                .padding(.horizontal, 20)

                // Recent Activity
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Activity")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, 20)
                        .accessibilityAddTraits(.isHeader)

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(viewModel.recentItems) { item in
                            ActivityRow(item: item)
                                .padding(.horizontal, 20)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(AppColors.backgroundPrimary)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Settings action
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(AppColors.textSecondary)
                }
                .accessibilityLabel("Settings")
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Activity Row Component
struct ActivityRow: View {
    let item: ActivityItem

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(item.color.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: item.icon)
                        .foregroundColor(item.color)
                )

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text(item.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            // Time
            Text(item.timeAgo)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.description), \(item.timeAgo)")
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
    }
}

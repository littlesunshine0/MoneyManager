//
//  LoadingView.swift
//  MyApp
//
//  Loading indicators and progress views

import SwiftUI
import Combine

struct LoadingView: View {
    var message: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
                .scaleEffect(1.2)

            if let message = message {
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary.opacity(0.95))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading\(message != nil ? ", " + message! : "")")
    }
}

// MARK: - Skeleton Loading
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(AppColors.backgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                AppColors.backgroundPrimary.opacity(0.5),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 300 : -300)
            )
            .clipped()
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                CustomButton(title: actionTitle, style: .primary, action: action)
                    .frame(width: 200)
            }
        }
        .padding(40)
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView(message: "Loading your data...")

            EmptyStateView(
                icon: "tray",
                title: "No Items Yet",
                message: "Add your first item to get started",
                actionTitle: "Add Item"
            ) {}

            VStack(spacing: 20) {
                SkeletonView()
                    .frame(height: 60)
                SkeletonView()
                    .frame(height: 60)
                SkeletonView()
                    .frame(height: 60)
            }
            .padding()
        }
    }
}

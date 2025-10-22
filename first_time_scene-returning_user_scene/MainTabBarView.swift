//
//  TabBarView.swift
//  MyApp
//
//  Main tab bar navigation (3-5 tabs per HIG)

import SwiftUI

struct MainTabBarView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            .accessibilityLabel("Home tab")

            // Discover Tab
            NavigationStack {
                DiscoverView()
            }
            .tabItem {
                Label("Discover", systemImage: "sparkles")
            }
            .tag(1)
            .accessibilityLabel("Discover tab")

            // Add/Create Tab (Center)
            NavigationStack {
                CreateView()
            }
            .tabItem {
                Label("Create", systemImage: "plus.circle.fill")
            }
            .tag(2)
            .accessibilityLabel("Create tab")

            // Activity Tab
            NavigationStack {
                ActivityView()
            }
            .tabItem {
                Label("Activity", systemImage: "chart.bar.fill")
            }
            .tag(3)
            .accessibilityLabel("Activity tab")

            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(4)
            .accessibilityLabel("Profile tab")
        }
        .tint(themeManager.currentTheme.primaryColor)
        .onChange(of: selectedTab) { _, _ in
            // Haptic feedback on tab change
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

// MARK: - Preview
struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
            .environmentObject(ThemeManager())
    }
}

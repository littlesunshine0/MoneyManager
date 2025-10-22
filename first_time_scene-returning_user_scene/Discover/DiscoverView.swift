//
//  DiscoverView.swift
//  MyApp

import SwiftUI

struct DiscoverView: View {
    var body: some View {
        VStack {
            Text("Discover")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Explore new content")
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary)
        .navigationTitle("Discover")
    }
}

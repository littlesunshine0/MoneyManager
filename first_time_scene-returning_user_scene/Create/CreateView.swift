//
//  CreateView.swift
//  MyApp

import SwiftUI

struct CreateView: View {
    var body: some View {
        VStack(spacing: 20) {
            CustomIconView(.plus, size: 80, color: AppColors.accent)

            Text("Create New")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Add a new goal or activity")
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary)
        .navigationTitle("Create")
    }
}

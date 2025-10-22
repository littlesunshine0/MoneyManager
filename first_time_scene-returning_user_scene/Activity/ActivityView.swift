//
//  ActivityView.swift
//  MyApp

import SwiftUI

struct ActivityView: View {
    var body: some View {
        VStack {
            Text("Activity")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track your progress")
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary)
        .navigationTitle("Activity")
    }
}

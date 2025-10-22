//
//  AccountsView.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//


import SwiftUI

// This is a simplified example of your AccountsView.
// You should adapt your existing view to follow this pattern.
struct AccountsFeatureView: View {
    
    @State private var selectedIndex: Int? = 1

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { idx in
                        // Use the custom AccountRowContainer for each row.
                        AccountRowContainer(
                            action: { withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) { selectedIndex = idx } },
                            cornerRadius: 12,
                            backgroundStyle: .rowBlueIndigoGradient,
                            elevation: .raised,
                            showBorder: true,
                            horizontalPadding: 16,
                            verticalPadding: 14,
                            isSelected: selectedIndex == idx,
                            selectionTint: RowAccentTokens.selectionBase
                        ) {
                            HStack {
                                RainbowIconBubble(systemName: "creditcard.fill", index: idx)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Account \(idx + 1)")
                                        .font(.headline)
                                    Text("Ending in ••••\(1234 + idx)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("$\(Int.random(in: 100...999)).\(Int.random(in: 10...99))")
                                        .font(.headline)
                                    Text("Updated just now")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(height: 64)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Accounts")
            // You can add your toolbar here if needed
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview("AccountsFeatureView") {
    AccountsFeatureView()
        .tint(RowAccentTokens.selectionBase)
}
#endif

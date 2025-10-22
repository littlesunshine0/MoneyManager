//
//  AccountColorPicker.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Account Color Picker
struct AccountColorPicker: View {
    @Binding var selectedColor: String
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let colors = [
        "#3882FF", "#14CC66", "#F03D4F", "#F5A500",
        "#B0CFFF", "#54E894", "#FF7885", "#FFC23D",
        "#1F56C2", "#0FB054", "#CC2E3D", "#D18A00",
        "#485566", "#8090A3", "#627085", "#1C2633"
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: DesignTokens.Spacing.sm) {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(themeManager.currentTheme.borderColor, lineWidth: selectedColor == color ? 3 : 1)
                        )
                        .scaleEffect(selectedColor == color ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedColor)
                }
                .buttonPress()
            }
        }
    }
}

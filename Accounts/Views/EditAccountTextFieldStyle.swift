//
//  EditAccountTextFieldStyle.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import SwiftUI

// MARK: - Edit Account Text Field Style
struct EditAccountTextFieldStyle: TextFieldStyle {
    @EnvironmentObject private var themeManager: ThemeManager
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
            .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)
    }
}

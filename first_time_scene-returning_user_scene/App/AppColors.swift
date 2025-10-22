//
//  AppColors.swift
//  MyApp
//
//  Semantic color system conforming to Apple HIG
//  Supports Light, Dark, and High Contrast modes

import SwiftUI

// MARK: - App Color System
/// Centralized color palette with automatic light/dark/high-contrast support
struct AppColors {
    
    // MARK: - Primary Colors
    /// Main brand accent color - used for primary actions, highlights
    /// Minimum contrast: 4.5:1 against backgrounds
    static let accent = Color("AccentColor")
    
    /// Primary brand color - used for key UI elements
    static let primary = Color("PrimaryColor")
    
    /// Secondary brand color - used for supporting elements
    static let secondary = Color("SecondaryColor")
    
    // MARK: - Text Colors
    /// Primary text color - highest contrast for body text
    /// Light: ~Black (rgba 0,0,0,0.85), Dark: White (rgba 255,255,255,0.85)
    static let textPrimary = Color("TextPrimary")
    
    /// Secondary text color - medium emphasis
    /// Light: Gray 60%, Dark: Gray 60%
    static let textSecondary = Color("TextSecondary")
    
    /// Tertiary text color - lowest emphasis, disabled states
    /// Light: Gray 40%, Dark: Gray 50%
    static let textTertiary = Color("TextTertiary")
    
    // MARK: - Background Colors
    /// Primary background - main app background
    /// Light: White/Light Gray, Dark: Black/Dark Gray
    static let backgroundPrimary = Color("BackgroundPrimary")
    
    /// Secondary background - grouped content, cards
    /// Light: Light Gray, Dark: Elevated Dark Gray
    static let backgroundSecondary = Color("BackgroundSecondary")
    
    /// Tertiary background - highest elevation, modals
    /// Light: White, Dark: Lighter Dark Gray
    static let backgroundTertiary = Color("BackgroundTertiary")
    
    // MARK: - UI Element Colors
    /// Separator lines, borders
    static let separator = Color("Separator")
    
    /// Button backgrounds (secondary style)
    static let buttonSecondary = Color("ButtonSecondary")
    
    /// Input field backgrounds
    static let inputBackground = Color("InputBackground")
    
    // MARK: - Semantic Colors
    /// Success states - green
    static let success = Color("SuccessColor")
    
    /// Warning states - yellow/orange
    static let warning = Color("WarningColor")
    
    /// Error states - red
    static let error = Color("ErrorColor")
    
    /// Info states - blue
    static let info = Color("InfoColor")
    
    // MARK: - System Colors (iOS native)
    /// Use system colors when appropriate for consistency
    static let systemBackground = Color(uiColor: .systemBackground)
    static let systemGroupedBackground = Color(uiColor: .systemGroupedBackground)
    static let label = Color(uiColor: .label)
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
}

// MARK: - Asset Catalog JSON Structure Documentation
/*
 Assets.xcassets Structure:
 
 Assets.xcassets/
 ├── AccentColor.colorset/
 │   └── Contents.json
 ├── PrimaryColor.colorset/
 │   └── Contents.json
 ├── SecondaryColor.colorset/
 │   └── Contents.json
 ├── TextPrimary.colorset/
 │   └── Contents.json
 ├── TextSecondary.colorset/
 │   └── Contents.json
 ├── TextTertiary.colorset/
 │   └── Contents.json
 ├── BackgroundPrimary.colorset/
 │   └── Contents.json
 ├── BackgroundSecondary.colorset/
 │   └── Contents.json
 ├── BackgroundTertiary.colorset/
 │   └── Contents.json
 ├── Separator.colorset/
 │   └── Contents.json
 ├── ButtonSecondary.colorset/
 │   └── Contents.json
 ├── InputBackground.colorset/
 │   └── Contents.json
 ├── SuccessColor.colorset/
 │   └── Contents.json
 ├── WarningColor.colorset/
 │   └── Contents.json
 ├── ErrorColor.colorset/
 │   └── Contents.json
 └── InfoColor.colorset/
     └── Contents.json

 Example Contents.json structure (see separate JSON files)
*/

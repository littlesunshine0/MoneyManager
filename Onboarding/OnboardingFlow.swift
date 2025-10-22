import SwiftUI
import Combine

// MARK: - Onboarding Flow View Model
@MainActor
public class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentStep: OnboardingStep = .welcome
    @Published public var isAnimating = false
    @Published public var selectedFeatures: Set<String> = []
    @Published public var userName = ""
    @Published public var userEmail = ""
    @Published public var enableNotifications = true
    @Published public var enableBiometrics = true
    @Published public var selectedCurrency = "USD"
    
    // MARK: - Computed Properties
    public var progress: Double {
        let totalSteps = OnboardingStep.allCases.count
        let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0
        return Double(currentIndex) / Double(totalSteps - 1)
    }
    
    public var canProceed: Bool {
        switch currentStep {
        case .welcome, .features, .permissions:
            return true
        case .personalization:
            return !userName.isEmpty && !userEmail.isEmpty
        case .completion:
            return true
        }
    }
    
    // MARK: - Methods
    public func nextStep() {
        guard canProceed else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            if let nextStep = currentStep.nextStep {
                currentStep = nextStep
            }
        }
    }
    
    public func previousStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if let previousStep = currentStep.previousStep {
                currentStep = previousStep
            }
        }
    }
    
    public func completeOnboarding() async {
        isAnimating = true
        
        // Simulate setup process
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // In real app, save user preferences and complete setup
        UserDefaults.standard.set(true, forKey: "com.moneymanager.onboarding.completed")
        UserDefaults.standard.set(userName, forKey: "com.moneymanager.user.name")
        UserDefaults.standard.set(userEmail, forKey: "com.moneymanager.user.email")
        UserDefaults.standard.set(enableNotifications, forKey: "com.moneymanager.notifications.enabled")
        UserDefaults.standard.set(enableBiometrics, forKey: "com.moneymanager.biometrics.enabled")
        UserDefaults.standard.set(selectedCurrency, forKey: "com.moneymanager.currency")
        
        isAnimating = false
    }
}

// MARK: - Onboarding Steps
public enum OnboardingStep: String, CaseIterable {
    case welcome = "welcome"
    case features = "features"
    case permissions = "permissions"
    case personalization = "personalization"
    case completion = "completion"
    
    public var title: String {
        switch self {
        case .welcome: return "Welcome to MoneyManager"
        case .features: return "Powerful Financial Tools"
        case .permissions: return "Secure & Private"
        case .personalization: return "Personalize Your Experience"
        case .completion: return "You're All Set!"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .welcome: return "Take control of your financial future with smart money management"
        case .features: return "Discover the tools that will transform how you manage money"
        case .permissions: return "Your financial data stays secure and private"
        case .personalization: return "Let's customize the app just for you"
        case .completion: return "Your financial journey starts now"
        }
    }
    
    public var nextStep: OnboardingStep? {
        let allCases = OnboardingStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex < allCases.count - 1 else {
            return nil
        }
        return allCases[currentIndex + 1]
    }
    
    public var previousStep: OnboardingStep? {
        let allCases = OnboardingStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex > 0 else {
            return nil
        }
        return allCases[currentIndex - 1]
    }
}

// MARK: - Main Onboarding Flow View
public struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var authManager: SystemAuthenticationManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    themeManager.currentTheme.primaryColor.opacity(0.1),
                    themeManager.currentTheme.backgroundColor
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                OnboardingProgressBar(progress: viewModel.progress)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.md)
                
                // Content Area
                TabView(selection: $viewModel.currentStep) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        onboardingView(for: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
                
                // Navigation Buttons
                OnboardingNavigationButtons(viewModel: viewModel) {
                    // Complete onboarding
                    Task {
                        await viewModel.completeOnboarding()
                        authManager.completeOnboarding()
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.xl)
            }
        }
        .overlay {
            if viewModel.isAnimating {
                OnboardingCompletionOverlay()
            }
        }
    }
    
    @ViewBuilder
    private func onboardingView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            WelcomeView()
                .environmentObject(viewModel)
        case .features:
            FeaturesView()
                .environmentObject(viewModel)
        case .permissions:
            PermissionsView()
                .environmentObject(viewModel)
        case .personalization:
            PersonalizationView()
                .environmentObject(viewModel)
        case .completion:
            CompletionView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Progress Bar
private struct OnboardingProgressBar: View {
    let progress: Double
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                CustomShapes.RoundedBar(cornerRadius: 4)
                    .fill(themeManager.currentTheme.backgroundColorTertiary)
                    .frame(height: 8)
                
                // Progress
                CustomShapes.RoundedBar(cornerRadius: 4)
                    .fill(themeManager.currentTheme.primaryColor)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue("\(Int(progress * 100)) percent complete")
    }
}

// MARK: - Welcome View
private struct WelcomeView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                
                Spacer()
                    .frame(height: DesignTokens.Spacing.xl)
                
                // App Icon with Animation
                ZStack {
                    // Pulsing background
                    Circle()
                        .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(viewModel.isAnimating ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: viewModel.isAnimating
                        )
                    
                    // App icon
                    VectorIcons.MoneySymbol()
                        .fill(themeManager.currentTheme.primaryColor)
                        .frame(width: 80, height: 80)
                        .scaleEffect(viewModel.isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: viewModel.isAnimating
                        )
                }
                .onAppear {
                    viewModel.isAnimating = true
                }
                .fadeInScale()
                
                // Welcome Text
                VStack(spacing: DesignTokens.Spacing.lg) {
                    Text(OnboardingStep.welcome.title)
                        .font(Typography.TextStyle.displayMedium)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .multilineTextAlignment(.center)
                        .fadeInScale(delay: 0.3)
                    
                    Text(OnboardingStep.welcome.subtitle)
                        .font(Typography.TextStyle.bodyLarge)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        .multilineTextAlignment(.center)
                        .fadeInScale(delay: 0.5)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                // Key Benefits
                VStack(spacing: DesignTokens.Spacing.lg) {
                    WelcomeBenefit(
                        icon: "chart.pie.fill",
                        title: "Smart Insights",
                        description: "AI-powered financial insights to optimize your spending"
                    )
                    .slideInFromLeading(delay: 0.7)
                    
                    WelcomeBenefit(
                        icon: "shield.fill",
                        title: "Bank-Level Security",
                        description: "Your data is encrypted and protected with biometric authentication"
                    )
                    .slideInFromTrailing(delay: 0.9)
                    
                    WelcomeBenefit(
                        icon: "icloud.fill",
                        title: "Seamless Sync",
                        description: "Access your data across all your devices with automatic sync"
                    )
                    .slideInFromLeading(delay: 1.1)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                Spacer()
            }
        }
    }
}

// MARK: - Welcome Benefit Item
private struct WelcomeBenefit: View {
    let icon: String
    let title: String
    let description: String
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            Circle()
                .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    LegacyIcon(icon, context: .inline, color: themeManager.currentTheme.primaryColor)
                )
            
            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(Typography.TextStyle.titleMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                
                Text(description)
                    .font(Typography.TextStyle.bodyMedium)
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

// MARK: - Features View
private struct FeaturesView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let features = [
        OnboardingFeature(
            icon: "creditcard.fill",
            title: "Account Management",
            description: "Connect and manage all your accounts in one secure place",
            color: "#3882FF"
        ),
        OnboardingFeature(
            icon: "chart.bar.fill",
            title: "Smart Budgeting",
            description: "Set budgets and get alerts to stay on track with your spending",
            color: "#14CC66"
        ),
        OnboardingFeature(
            icon: "target",
            title: "Savings Goals",
            description: "Set and track progress toward your financial goals",
            color: "#F5A500"
        ),
        OnboardingFeature(
            icon: "chart.xyaxis.line",
            title: "Financial Reports",
            description: "Get detailed insights into your spending and income patterns",
            color: "#B0CFFF"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                
                // Header
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text(OnboardingStep.features.title)
                        .font(Typography.TextStyle.headlineLarge)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .multilineTextAlignment(.center)
                        .fadeInScale()
                    
                    Text(OnboardingStep.features.subtitle)
                        .font(Typography.TextStyle.bodyLarge)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        .multilineTextAlignment(.center)
                        .fadeInScale(delay: 0.2)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.xl)
                
                // Features Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignTokens.Spacing.md) {
                    ForEach(Array(features.enumerated()), id: \.1.id) { index, feature in
                        FeatureCard(feature: feature)
                            .fadeInScale(delay: 0.4 + Double(index) * 0.1)
                            .onTapGesture {
                                let key = feature.id.uuidString
                                if viewModel.selectedFeatures.contains(key) {
                                    viewModel.selectedFeatures.remove(key)
                                } else {
                                    viewModel.selectedFeatures.insert(key)
                                }
                            }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                // Animation Showcase
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text("See Your Money Flow")
                        .font(Typography.TextStyle.titleMedium)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .slideInFromBottom(delay: 0.8)
                    
                    // Money Flow Animation
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.lg)
                            .fill(themeManager.currentTheme.backgroundColorSecondary)
                            .frame(height: 100)
                        
                        MoneyFlowAnimation(
                            from: CGPoint(x: -80, y: 0),
                            to: CGPoint(x: 80, y: 0),
                            amount: 250.0,
                            duration: 2.0
                        )
                    }
                    .slideInFromBottom(delay: 1.0)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                Spacer()
            }
        }
    }
}

// MARK: - Feature Card
private struct FeatureCard: View {
    let feature: OnboardingFeature
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    private var isSelected: Bool {
        viewModel.selectedFeatures.contains(feature.id.uuidString)
    }
    
    var body: some View {
        FinancialCard(shadowLevel: isSelected ? .heavy : .light) {
            VStack(spacing: DesignTokens.Spacing.md) {
                // Icon
                Circle()
                    .fill(Color(hex: feature.color).opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        LegacyIcon(feature.icon, context: .inline, color: Color(hex: feature.color))
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                
                // Content
                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text(feature.title)
                        .font(Typography.TextStyle.titleSmall)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(feature.description)
                        .font(Typography.TextStyle.bodySmall)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Selection Indicator
                if isSelected {
                    LegacyIcon("checkmark.circle.fill", context: .status, color: Color(hex: feature.color))
                        .scaleEffect(isSelected ? 1.0 : 0.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                }
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .buttonPress()
    }
}

// MARK: - Permissions View
private struct PermissionsView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                
                // Header
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text(OnboardingStep.permissions.title)
                        .font(Typography.TextStyle.headlineLarge)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .multilineTextAlignment(.center)
                        .fadeInScale()
                    
                    Text(OnboardingStep.permissions.subtitle)
                        .font(Typography.TextStyle.bodyLarge)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        .multilineTextAlignment(.center)
                        .fadeInScale(delay: 0.2)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.xl)
                
                // Biometric Animation
                BiometricScanAnimation(type: .faceID)
                    .frame(width: 120, height: 120)
                    .fadeInScale(delay: 0.4)
                
                // Permissions List
                VStack(spacing: DesignTokens.Spacing.lg) {
                    PermissionItem(
                        icon: "faceid",
                        title: "Biometric Authentication",
                        description: "Use Face ID or Touch ID for secure app access",
                        isEnabled: $viewModel.enableBiometrics
                    )
                    .slideInFromLeading(delay: 0.6)
                    
                    PermissionItem(
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Get alerts for budgets, goals, and important transactions",
                        isEnabled: $viewModel.enableNotifications
                    )
                    .slideInFromTrailing(delay: 0.8)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                // Security Message
                FinancialCard(shadowLevel: .light) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        LegacyIcon("shield.fill", context: .inline, color: DesignTokens.Colors.success)
                        
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text("Your Privacy Matters")
                                .font(Typography.TextStyle.titleSmall)
                                .foregroundColor(themeManager.currentTheme.textColorPrimary)
                            
                            Text("Your financial data is encrypted and never shared with third parties.")
                                .font(Typography.TextStyle.bodySmall)
                                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        }
                        
                        Spacer()
                    }
                }
                .slideInFromBottom(delay: 1.0)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                Spacer()
            }
        }
    }
}

// MARK: - Permission Item
private struct PermissionItem: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        FinancialCard(shadowLevel: .light) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Icon
                Circle()
                    .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        LegacyIcon(icon, context: .inline, color: themeManager.currentTheme.primaryColor)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(Typography.TextStyle.titleSmall)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    
                    Text(description)
                        .font(Typography.TextStyle.bodySmall)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(themeManager.currentTheme.primaryColor)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isEnabled ? .isSelected : [])
    }
}

// MARK: - Personalization View
private struct PersonalizationView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isEmailFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                
                // Header
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text(OnboardingStep.personalization.title)
                        .font(Typography.TextStyle.headlineLarge)
                        .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        .multilineTextAlignment(.center)
                        .fadeInScale()
                    
                    Text(OnboardingStep.personalization.subtitle)
                        .font(Typography.TextStyle.bodyLarge)
                        .foregroundColor(themeManager.currentTheme.textColorSecondary)
                        .multilineTextAlignment(.center)
                        .fadeInScale(delay: 0.2)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.xl)
                
                // Form Fields
                VStack(spacing: DesignTokens.Spacing.lg) {
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("What should we call you?")
                            .font(Typography.TextStyle.titleSmall)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        
                        TextField("Your name", text: $viewModel.userName)
                            .padding()
                            .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
                            .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)
                            .focused($isNameFieldFocused)
                            .accessibilityLabel("Your name")
                            .accessibilityHint("Enter your preferred name")
                    }
                    .slideInFromLeading(delay: 0.4)
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Email Address")
                            .font(Typography.TextStyle.titleSmall)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        
                        TextField("your.email@example.com", text: $viewModel.userEmail)
                            .padding()
                            .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
                            .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($isEmailFieldFocused)
                            .accessibilityLabel("Email address")
                            .accessibilityHint("Enter your email address")
                    }
                    .slideInFromTrailing(delay: 0.6)
                    
                    // Currency Selection
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Preferred Currency")
                            .font(Typography.TextStyle.titleSmall)
                            .foregroundColor(themeManager.currentTheme.textColorPrimary)
                        
                        Menu {
                            ForEach(["USD", "EUR", "GBP", "CAD", "AUD"], id: \.self) { currency in
                                Button(currency) {
                                    viewModel.selectedCurrency = currency
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedCurrency)
                                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                                Spacer()
                                LegacyIcon("chevron.down", context: .inline, color: themeManager.currentTheme.textColorSecondary)
                            }
                            .padding()
                            .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
                            .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)
                        }
                        .accessibilityLabel("Select currency")
                        .accessibilityValue(viewModel.selectedCurrency)
                    }
                    .slideInFromLeading(delay: 0.8)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                Spacer()
            }
        }
        .onTapGesture {
            isNameFieldFocused = false
            isEmailFieldFocused = false
        }
    }
}

// MARK: - Completion View
private struct CompletionView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            
            Spacer()
            
            // Success Animation
            StackingCoinsAnimation(numberOfCoins: 5, coinSize: 40)
                .frame(height: 200)
                .fadeInScale()
            
            // Completion Message
            VStack(spacing: DesignTokens.Spacing.lg) {
                Text(OnboardingStep.completion.title)
                    .font(Typography.TextStyle.displayMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .multilineTextAlignment(.center)
                    .fadeInScale(delay: 0.5)
                
                Text(OnboardingStep.completion.subtitle)
                    .font(Typography.TextStyle.bodyLarge)
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    .multilineTextAlignment(.center)
                    .fadeInScale(delay: 0.7)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            
            // Features Summary
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("You're ready to:")
                    .font(Typography.TextStyle.titleMedium)
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .slideInFromBottom(delay: 0.9)
                
                VStack(spacing: DesignTokens.Spacing.sm) {
                    CompletionFeature(icon: "plus.circle.fill", text: "Track your spending")
                        .slideInFromLeading(delay: 1.1)
                    CompletionFeature(icon: "chart.bar.fill", text: "Manage your budgets")
                        .slideInFromTrailing(delay: 1.3)
                    CompletionFeature(icon: "target", text: "Reach your goals")
                        .slideInFromLeading(delay: 1.5)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            
            Spacer()
        }
    }
}

// MARK: - Completion Feature
private struct CompletionFeature: View {
    let icon: String
    let text: String
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            LegacyIcon(icon, context: .inline, color: DesignTokens.Colors.success)
            
            Text(text)
                .font(Typography.TextStyle.bodyMedium)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Navigation Buttons
private struct OnboardingNavigationButtons: View {
    let viewModel: OnboardingViewModel
    let onComplete: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            
            // Back Button
            if viewModel.currentStep != .welcome {
                Button("Back") {
                    viewModel.previousStep()
                }
                .font(Typography.TextStyle.buttonText)
                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .deepSquircleBackground(themeManager.currentTheme.backgroundColorSecondary)
                .deepSquircleBorder(lineWidth: 1, color: themeManager.currentTheme.borderColor)
                .accessibleButton(title: "Back", action: "goes to previous step")
            }
            
            // Next/Complete Button
            BrandedButton(
                viewModel.currentStep == .completion ? "Get Started" : "Continue",
                style: .primary
            ) {
                if viewModel.currentStep == .completion {
                    onComplete()
                } else {
                    viewModel.nextStep()
                }
            }
            .disabled(!viewModel.canProceed)
            .opacity(viewModel.canProceed ? 1.0 : 0.6)
        }
    }
}

// MARK: - Completion Overlay
private struct OnboardingCompletionOverlay: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.overlayColor
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.lg) {
                ProgressIndicator(
                    progress: 1.0,
                    size: 80,
                    thickness: 8,
                    color: themeManager.currentTheme.primaryColor
                )
                
                Text("Setting up your account...")
                    .font(Typography.TextStyle.titleMedium)
                    .foregroundColor(themeManager.currentTheme.textColorInverse)
            }
        }
        .animation(.easeInOut, value: true)
    }
}

// MARK: - Supporting Types
private struct OnboardingFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: String
}

#if DEBUG
struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingFlowView()
                .environmentObject(SystemAuthenticationManager())
                .environmentObject(ThemeManager())
                .environmentObject(AccessibilitySystem.AccessibilityManager())
                .previewDisplayName("Onboarding Flow")
            
            WelcomeView()
                .environmentObject(OnboardingViewModel())
                .environmentObject(ThemeManager())
                .previewDisplayName("Welcome")
            
            FeaturesView()
                .environmentObject(OnboardingViewModel())
                .environmentObject(ThemeManager())
                .previewDisplayName("Features")
        }
    }
}
#endif

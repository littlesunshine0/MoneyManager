import SwiftUI
import LocalAuthentication
import Combine
import Security

// MARK: - Local, unambiguous animation/accessibility helpers used only in this file
private struct SysFadeInScale: ViewModifier {
    let delay: Double
    @State private var appeared = false
    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1.0 : 0.95)
            .opacity(appeared ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(delay)) {
                    appeared = true
                }
            }
    }
}
private struct SysSlideIn: ViewModifier {
    enum Direction { case bottom }
    let direction: Direction
    let delay: Double
    @State private var appeared = false
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: appeared ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(delay)) {
                    appeared = true
                }
            }
    }
}
private struct SysBounceIn: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0.8
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
                    scale = 1.0
                }
            }
    }
}
private struct SysAccessibilityButton: ViewModifier {
    let title: String
    let action: String
    func body(content: Content) -> some View {
        content
            .accessibilityLabel(Text(title))
            .accessibilityHint(Text(action))
    }
}
private struct SysOpacityModifier: ViewModifier {
    let value: Double
    func body(content: Content) -> some View {
        content.opacity(value)
    }
}

extension View {
    func sysFadeInScale(delay: Double = 0) -> some View { modifier(SysFadeInScale(delay: delay)) }
    func sysSlideInFromBottom(delay: Double = 0) -> some View { modifier(SysSlideIn(direction: .bottom, delay: delay)) }
    func sysBounceIn(delay: Double = 0) -> some View { modifier(SysBounceIn(delay: delay)) }
    func sysAccessibleButton(title: String, action: String) -> some View { modifier(SysAccessibilityButton(title: title, action: action)) }
    func sysOpacity(_ value: Double) -> some View { modifier(SysOpacityModifier(value: value)) }
}

// Compatibility shim: provide a local press effect to avoid ambiguous buttonPress() overloads
private struct AuthPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension View {
    func authButtonPress() -> some View {
        self.buttonStyle(AuthPressStyle())
    }
}

// MARK: - Authentication Manager
@MainActor
public class SystemAuthenticationManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isAuthenticated = false
    @Published public var isOnboardingComplete = false
    @Published public var currentUser: AppUser?
    @Published public var authenticationState: SystemAuthenticationState = .unauthenticated
    @Published public var biometricType: SystemBiometricType = .none
    @Published public var authenticationError: SystemAuthenticationError?
    @Published public var isLoading = false
    
    // MARK: - Private Properties
    private let keychain = SystemKeychainService()
    private let biometricService = SystemBiometricAuthenticationService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - User Defaults Keys
    private let onboardingCompletedKey = "com.moneymanager.onboarding.completed"
    private let biometricEnabledKey = "com.moneymanager.biometric.enabled"
    private let userEmailKey = "com.moneymanager.user.email"
    
    public init() {
        checkOnboardingStatus()
        setupBiometricType()
        checkExistingAuthentication()
    }
    
    // MARK: - Authentication State Management
    
    public func checkExistingAuthentication() {
        isLoading = true
        
        // Check if user has completed onboarding
        guard isOnboardingComplete else {
            authenticationState = .needsOnboarding
            isLoading = false
            return
        }
        
        // Check for stored credentials or biometric setup
        if hasBiometricEnabled() {
            authenticationState = .needsBiometric
        } else if hasStoredCredentials() {
            authenticationState = .needsPasscode
        } else {
            authenticationState = .needsSetup
        }
        
        isLoading = false
    }
    
    public func authenticateWithBiometrics() async {
        guard biometricType != .none else {
            authenticationError = .biometricNotAvailable
            return
        }
        
        isLoading = true
        authenticationError = nil
        
        do {
            let success = try await biometricService.authenticateUser()
            
            if success {
                await loadUserData()
                isAuthenticated = true
                authenticationState = .authenticated
            } else {
                authenticationError = .biometricFailed
                authenticationState = .needsPasscode
            }
        } catch {
            authenticationError = .biometricError(error.localizedDescription)
            authenticationState = .needsPasscode
        }
        
        isLoading = false
    }
    
    public func authenticateWithPasscode(_ passcode: String) async {
        isLoading = true
        authenticationError = nil
        
        // Validate passcode
        guard validatePasscode(passcode) else {
            authenticationError = .invalidPasscode
            isLoading = false
            return
        }
        
        await loadUserData()
        isAuthenticated = true
        authenticationState = .authenticated
        isLoading = false
    }
    
    public func setupPasscode(_ passcode: String, confirmPasscode: String) async {
        guard passcode == confirmPasscode else {
            authenticationError = .passcodeNotMatching
            return
        }
        
        guard passcode.count >= 4 else {
            authenticationError = .passcodeInvalid
            return
        }
        
        isLoading = true
        authenticationError = nil
        
        // Store passcode securely
        keychain.store(passcode, for: .userPasscode)
        
        // Enable biometric if available
        if biometricType != .none {
            await setupBiometricAuthentication()
        }
        
        await loadUserData()
        isAuthenticated = true
        authenticationState = .authenticated
        isLoading = false
    }
    
    public func setupBiometricAuthentication() async {
        guard biometricType != .none else { return }
        
        do {
            let success = try await biometricService.enableBiometricAuthentication()
            if success {
                UserDefaults.standard.set(true, forKey: biometricEnabledKey)
                keychain.store("biometric_enabled", for: .biometricFlag)
            }
        } catch {
            authenticationError = .biometricError(error.localizedDescription)
        }
    }
    
    public func logout() {
        isAuthenticated = false
        currentUser = nil
        authenticationState = isOnboardingComplete ? .needsBiometric : .needsOnboarding
        
        // Clear sensitive data but keep user preferences
        keychain.delete(.userPasscode)
        keychain.delete(.biometricFlag)
        UserDefaults.standard.set(false, forKey: biometricEnabledKey)
    }
    
    public func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
        authenticationState = .needsSetup
    }
    
    // MARK: - Private Methods
    
    private func checkOnboardingStatus() {
        isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
    }
    
    private func setupBiometricType() {
        biometricType = biometricService.biometricType
    }
    
    fileprivate func hasBiometricEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: biometricEnabledKey) &&
               keychain.retrieve(.biometricFlag) != nil
    }
    
    private func hasStoredCredentials() -> Bool {
        return keychain.retrieve(.userPasscode) != nil
    }
    
    private func validatePasscode(_ passcode: String) -> Bool {
        guard let storedPasscode = keychain.retrieve(.userPasscode) else {
            return false
        }
        return passcode == storedPasscode
    }
    
    private func loadUserData() async {
        // In a real app, this would load from persistent storage
        // For now, create a sample user
        if currentUser == nil {
            currentUser = AppUser(
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@example.com"
            )
            currentUser?.createSampleData()
        }
    }
}

// MARK: - Authentication State
public enum SystemAuthenticationState {
    case unauthenticated
    case needsOnboarding
    case needsSetup
    case needsPasscode
    case needsBiometric
    case authenticated
    
    var description: String {
        switch self {
        case .unauthenticated: return "Not authenticated"
        case .needsOnboarding: return "Needs onboarding"
        case .needsSetup: return "Needs setup"
        case .needsPasscode: return "Needs passcode"
        case .needsBiometric: return "Needs biometric"
        case .authenticated: return "Authenticated"
        }
    }
}

// MARK: - Biometric Type
public enum SystemBiometricType {
    case none
    case faceID
    case touchID
    case opticID
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        }
    }
    
    var iconName: String {
        switch self {
        case .none: return "lock"
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        }
    }
}

// MARK: - Authentication Errors
public enum SystemAuthenticationError: LocalizedError {
    case biometricNotAvailable
    case biometricFailed
    case biometricError(String)
    case invalidPasscode
    case passcodeNotMatching
    case passcodeInvalid
    case userNotFound
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device"
        case .biometricFailed:
            return "Biometric authentication failed. Please try again or use your passcode."
        case .biometricError(let message):
            return "Biometric error: \(message)"
        case .invalidPasscode:
            return "Invalid passcode. Please try again."
        case .passcodeNotMatching:
            return "Passcodes do not match. Please try again."
        case .passcodeInvalid:
            return "Passcode must be at least 4 digits."
        case .userNotFound:
            return "User not found. Please check your credentials."
        case .networkError:
            return "Network error. Please check your connection and try again."
        }
    }
}

// MARK: - Biometric Authentication Service
public class SystemBiometricAuthenticationService {
    
    // Compute using a fresh LAContext (no stored state)
    public nonisolated var biometricType: SystemBiometricType {
        var error: NSError?
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                return .faceID
            case .touchID:
                return .touchID
            case .opticID:
                return .opticID
            default:
                return .none
            }
        }
        
        return .none
    }
    
    // Use a fresh LAContext per call; run on caller's actor without sending self
    public nonisolated(nonsending)
    func authenticateUser() async throws -> Bool {
        let reason = "Authenticate to access your financial data"
        let context = LAContext()
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // Use a fresh LAContext per call; run on caller's actor without sending self
    public nonisolated(nonsending)
    func enableBiometricAuthentication() async throws -> Bool {
        let reason = "Enable biometric authentication for secure access"
        let context = LAContext()
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
}

// MARK: - Keychain Service
public class SystemKeychainService {
    
    public enum KeychainKey: String {
        case userPasscode = "com.moneymanager.user.passcode"
        case biometricFlag = "com.moneymanager.biometric.flag"
        case userToken = "com.moneymanager.user.token"
    }
    
    public func store(_ value: String, for: KeychainKey) {
        let data = Data(value.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: `for`.rawValue,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    public func retrieve(_ key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            // Use native Bool for clarity on some toolchains
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    public func delete(_ key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Authentication Views

/// Main Authentication View
public struct SystemAuthenticationView: View {
    @EnvironmentObject private var authManager: SystemAuthenticationManager
    @EnvironmentObject private var themeManager: AuthThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystemShim.AccessibilityManager
    
    // A safe binding for the alert presentation that clears the error on dismiss
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { authManager.authenticationError != nil },
            set: { newValue in
                if newValue == false {
                    authManager.authenticationError = nil
                }
            }
        )
    }
    
    public var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                switch authManager.authenticationState {
                case .needsSetup:
                    SystemPasscodeSetupView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                case .needsPasscode:
                    SystemPasscodeEntryView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    
                case .needsBiometric:
                    SystemBiometricAuthenticationView()
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                    
                default:
                    SystemPasscodeEntryView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authManager.authenticationState)
        .alert("Authentication Error", isPresented: errorBinding) {
            Button("OK") {
                authManager.authenticationError = nil
            }
        } message: {
            // Always return a Text to satisfy the builder
            Text(authManager.authenticationError?.localizedDescription ?? "")
        }
    }
}

/// Local, unambiguous biometric icon animation to avoid type-name conflicts
private struct SystemBiometricScanIcon: View {
    enum Kind { case faceID, touchID }
    let kind: Kind
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 4)
                .scaleEffect(pulse ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
            
            Image(systemName: kind == .faceID ? "faceid" : "touchid")
                .font(.system(size: 44))
                .foregroundColor(.accentColor)
        }
        .onAppear { pulse = true }
    }
}

// Local, unambiguous app logo shape to avoid VectorIcons naming collisions
private struct SystemAppLogoIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Simple shield-like shape with vertical line, visually neutral
        let inset = min(rect.width, rect.height) * 0.15
        let bodyRect = rect.insetBy(dx: inset, dy: inset)
        p.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: inset * 0.6, height: inset * 0.6))
        p.move(to: CGPoint(x: rect.midX, y: bodyRect.minY + inset * 0.4))
        p.addLine(to: CGPoint(x: rect.midX, y: bodyRect.maxY - inset * 0.4))
        return p
    }
}

/// Biometric Authentication View
public struct SystemBiometricAuthenticationView: View {
    @EnvironmentObject private var authManager: SystemAuthenticationManager
    @EnvironmentObject private var themeManager: AuthThemeManager
    @State private var showingPasscodeOption = false
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            
            Spacer()
            
            // App Icon/Logo (use local shape to avoid ambiguous VectorIcons)
            SystemAppLogoIcon()
                .fill(themeManager.currentTheme.primaryColor)
                .frame(width: 80, height: 80)
                .sysFadeInScale()
            
            // Welcome Text
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Welcome Back")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .sysFadeInScale(delay: 0.2)
                
                Text("Use \(authManager.biometricType.displayName) to access your financial data securely")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    .multilineTextAlignment(.center)
                    .sysFadeInScale(delay: 0.3)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            
            Spacer()
            
            // Biometric Animation (local to avoid ambiguity)
            SystemBiometricScanIcon(kind: authManager.biometricType == .faceID ? .faceID : .touchID)
                .frame(width: 120, height: 120)
                .onTapGesture {
                    Task {
                        await authManager.authenticateWithBiometrics()
                    }
                }
                .accessibilityLabel("Authenticate with \(authManager.biometricType.displayName)")
                .accessibilityHint("Double tap to authenticate")
                .sysFadeInScale(delay: 0.4)
            
            // Instruction Text
            Text("Tap to authenticate")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(themeManager.currentTheme.textColorTertiary)
                .sysFadeInScale(delay: 0.5)
            
            Spacer()
            
            // Alternative Options
            VStack(spacing: DesignTokens.Spacing.md) {
                
                // Use Passcode Button
                Button("Use Passcode Instead") {
                    authManager.authenticationState = .needsPasscode
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .sysAccessibleButton(title: "Use Passcode Instead", action: "switches to passcode entry")
                .sysSlideInFromBottom(delay: 0.6)
                
                // Logout Button
                Button("Sign Out") {
                    authManager.logout()
                }
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                .sysAccessibleButton(title: "Sign Out", action: "signs out of the app")
                .sysSlideInFromBottom(delay: 0.7)
            }
            .padding(.bottom, DesignTokens.Spacing.xl)
        }
        .padding(DesignTokens.Spacing.lg)
        .onAppear {
            // Auto-trigger biometric authentication
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task {
                    await authManager.authenticateWithBiometrics()
                }
            }
        }
    }
}

/// Passcode Entry View
public struct SystemPasscodeEntryView: View {
    @EnvironmentObject private var authManager: SystemAuthenticationManager
    @EnvironmentObject private var themeManager: AuthThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystemShim.AccessibilityManager
    @State private var passcode = ""
    @State private var showingError = false
    
    private let passcodeLength = 4
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            
            Spacer()
            
            // Title
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Enter Passcode")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .sysFadeInScale()
                
                Text("Enter your 4-digit passcode to continue")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    .multilineTextAlignment(.center)
                    .sysFadeInScale(delay: 0.1)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            
            Spacer()
            
            // Passcode Dots
            HStack(spacing: DesignTokens.Spacing.lg) {
                ForEach(0..<passcodeLength, id: \.self) { index in
                    Circle()
                        .fill(index < passcode.count ?
                              themeManager.currentTheme.primaryColor :
                              themeManager.currentTheme.borderColor)
                        .frame(width: 20, height: 20)
                        .scaleEffect(index < passcode.count ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: passcode.count)
                        .sysBounceIn(delay: Double(index) * 0.1)
                }
            }
            .padding(.vertical, DesignTokens.Spacing.lg)
            
            Spacer()
            
            // Number Pad
            SystemPasscodeNumberPad(passcode: $passcode, maxLength: passcodeLength) {
                Task {
                    await authManager.authenticateWithPasscode(passcode)
                    if !authManager.isAuthenticated {
                        // Clear passcode on failed attempt
                        passcode = ""
                        showingError = true
                    }
                }
            }
            .sysSlideInFromBottom(delay: 0.3)
            
            // Biometric Option (if available)
            if authManager.biometricType != .none && authManager.hasBiometricEnabled() {
                Button {
                    Task {
                        await authManager.authenticateWithBiometrics()
                    }
                } label: {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        LegacyIcon(authManager.biometricType.iconName, context: .inline)
                        Text("Use \(authManager.biometricType.displayName)")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .sysAccessibleButton(
                    title: "Use \(authManager.biometricType.displayName)",
                    action: "authenticates with biometrics"
                )
                .sysSlideInFromBottom(delay: 0.5)
                .padding(.top, DesignTokens.Spacing.md)
            }
            
            Spacer()
        }
        .padding(DesignTokens.Spacing.lg)
        .shake(showingError)
        .onChange(of: showingError) { _ in
            if showingError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingError = false
                }
            }
        }
    }
}

/// Passcode Setup View
public struct SystemPasscodeSetupView: View {
    @EnvironmentObject private var authManager: SystemAuthenticationManager
    @EnvironmentObject private var themeManager: AuthThemeManager
    @State private var passcode = ""
    @State private var confirmPasscode = ""
    @State private var step: SetupStep = .initial
    
    private let passcodeLength = 4
    
    private enum SetupStep {
        case initial
        case confirm
    }
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            
            Spacer()
            
            // Title
            VStack(spacing: DesignTokens.Spacing.md) {
                Text(step == .initial ? "Create Passcode" : "Confirm Passcode")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(themeManager.currentTheme.textColorPrimary)
                    .animation(.easeInOut, value: step)
                
                Text(step == .initial ?
                     "Create a 4-digit passcode to secure your financial data" :
                     "Re-enter your passcode to confirm")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut, value: step)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            
            Spacer()
            
            // Passcode Dots
            HStack(spacing: DesignTokens.Spacing.lg) {
                ForEach(0..<passcodeLength, id: \.self) { index in
                    Circle()
                        .fill(index < currentPasscode.count ?
                              themeManager.currentTheme.primaryColor :
                              themeManager.currentTheme.borderColor)
                        .frame(width: 20, height: 20)
                        .scaleEffect(index < currentPasscode.count ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentPasscode.count)
                }
            }
            .padding(.vertical, DesignTokens.Spacing.lg)
            
            Spacer()
            
            // Number Pad
            SystemPasscodeNumberPad(passcode: currentPasscodeBinding, maxLength: passcodeLength) {
                handlePasscodeComplete()
            }
            
            Spacer()
        }
        .padding(DesignTokens.Spacing.lg)
    }
    
    private var currentPasscode: String {
        step == .initial ? passcode : confirmPasscode
    }
    
    private var currentPasscodeBinding: Binding<String> {
        step == .initial ? $passcode : $confirmPasscode
    }
    
    private func handlePasscodeComplete() {
        switch step {
        case .initial:
            step = .confirm
        case .confirm:
            Task {
                await authManager.setupPasscode(passcode, confirmPasscode: confirmPasscode)
            }
        }
    }
}

/// Number Pad Component
public struct SystemPasscodeNumberPad: View {
    @Binding var passcode: String
    let maxLength: Int
    let onComplete: () -> Void
    
    @EnvironmentObject private var themeManager: AuthThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystemShim.AccessibilityManager
    
    private let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"]
    ]
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(row, id: \.self) { number in
                        SystemNumberPadButton(
                            number: number,
                            passcode: $passcode,
                            maxLength: maxLength,
                            onComplete: onComplete
                        )
                    }
                }
            }
        }
    }
}

/// Number Pad Button
private struct SystemNumberPadButton: View {
    let number: String
    @Binding var passcode: String
    let maxLength: Int
    let onComplete: () -> Void
    
    @EnvironmentObject private var themeManager: AuthThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystemShim.AccessibilityManager
    
    var body: some View {
        Button {
            handleTap()
        } label: {
            Text(number)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(number.isEmpty ? .clear : themeManager.currentTheme.textColorPrimary)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(number.isEmpty ? .clear : themeManager.currentTheme.backgroundColorSecondary)
                )
        }
        .disabled(number.isEmpty)
        .authButtonPress()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
    
    private var accessibilityLabel: String {
        if number == "⌫" {
            return "Delete"
        } else if number.isEmpty {
            return ""
        } else {
            return number
        }
    }
    
    private var accessibilityHint: String {
        if number == "⌫" {
            return "Removes the last entered digit"
        } else if number.isEmpty {
            return ""
        } else {
            return "Enters digit \(number)"
        }
    }
    
    private func handleTap() {
        accessibilityManager.provideTactileFeedback(for: .buttonTapped)
        
        if number == "⌫" {
            if !passcode.isEmpty {
                passcode.removeLast()
            }
        } else if !number.isEmpty && passcode.count < maxLength {
            passcode.append(number)
            
            if passcode.count == maxLength {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onComplete()
                }
            }
        }
    }
}

// MARK: - Shake Effect
private struct ShakeEffect: ViewModifier {
    let shakes: Int
    let animatableData: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(x: sin(animatableData * .pi * CGFloat(shakes)) * 5)
    }
}

extension View {
    func shake(_ isShaking: Bool) -> some View {
        modifier(ShakeEffect(
            shakes: isShaking ? 2 : 0,
            animatableData: isShaking ? 1 : 0
        ))
        .animation(.easeInOut(duration: 0.5), value: isShaking)
    }
}

#if DEBUG
struct SystemAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Biometric Authentication
            SystemBiometricAuthenticationView()
                .environmentObject(SystemAuthenticationManager())
                .environmentObject(AuthThemeManager())
                .environmentObject(AccessibilitySystemShim.AccessibilityManager())
                .previewDisplayName("Biometric Auth")
            
            // Passcode Entry
            SystemPasscodeEntryView()
                .environmentObject(SystemAuthenticationManager())
                .environmentObject(AuthThemeManager())
                .environmentObject(AccessibilitySystemShim.AccessibilityManager())
                .previewDisplayName("Passcode Entry")
            
            // Passcode Setup
            SystemPasscodeSetupView()
                .environmentObject(SystemAuthenticationManager())
                .environmentObject(AuthThemeManager())
                .environmentObject(AccessibilitySystemShim.AccessibilityManager())
                .previewDisplayName("Passcode Setup")
        }
    }
}
#endif

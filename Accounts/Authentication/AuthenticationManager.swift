import SwiftUI
import AuthenticationServices
import LocalAuthentication
import Combine

// MARK: - Authentication Manager
@MainActor
public class AuthenticationManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isAuthenticated = false
    @Published public var currentUser: AuthUser?
    @Published public var authenticationState: AuthenticationState = .unauthenticated
    @Published public var showingBiometricPrompt = false
    @Published public var authError: AuthError?
    @Published public var isLoading = false
    
    // Login Flow
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var isEmailValid = false
    @Published public var isPasswordValid = false
    @Published public var showingPasswordRequirements = false
    
    // UI State
    @Published public var currentLoginStep: LoginStep = .welcome
    @Published public var keyboardHeight: CGFloat = 0
    @Published public var loginAnimation: LoginAnimationPhase = .idle
    @Published public var showingSecurityTips = false
    
    // Biometric Authentication
    @Published public var biometricType: BiometricType = .none
    @Published public var isBiometricEnabled = false
    @Published public var biometricEnrollmentStep: BiometricEnrollmentStep = .prompt
    
    // Security
    private let keychain = KeychainManager()
    private let biometricAuth = BiometricAuthManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init() {
        setupKeyboardObservers()
        checkBiometricAvailability()
        loadStoredCredentials()
        setupFormValidation()
    }
    
    // MARK: - Authentication Methods
    public func signIn() async {
        guard isEmailValid && isPasswordValid else {
            authError = .invalidCredentials
            return
        }
        
        isLoading = true
        loginAnimation = .authenticating
        authError = nil
        
        do {
            // Simulate network delay for animation
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // In real implementation, call authentication API
            let user = AuthUser(
                id: UUID(),
                email: email,
                firstName: firstName.isEmpty ? "User" : firstName,
                lastName: lastName,
                isVerified: true,
                lastLoginDate: Date(),
                securityLevel: .high,
                preferredAuthMethod: isBiometricEnabled ? biometricType.authMethod : .password
            )
            
            // Store credentials securely
            try await keychain.storeCredentials(email: email, password: password)
            
            // Update state
            await MainActor.run {
                currentUser = user
                authenticationState = .authenticated
                isAuthenticated = true
                loginAnimation = .success
                currentLoginStep = .success
            }
            
            // Small delay for success animation
            try await Task.sleep(nanoseconds: 500_000_000)
            
        } catch {
            await MainActor.run {
                authError = .networkError
                loginAnimation = .error
                isLoading = false
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func signUp() async {
        guard isEmailValid && isPasswordValid else {
            authError = .invalidInput
            return
        }
        
        isLoading = true
        loginAnimation = .authenticating
        authError = nil
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Create new user
            let user = AuthUser(
                id: UUID(),
                email: email,
                firstName: firstName,
                lastName: lastName,
                isVerified: false,
                lastLoginDate: Date(),
                securityLevel: .medium
            )
            
            await MainActor.run {
                currentUser = user
                authenticationState = .needsVerification
                loginAnimation = .success
                currentLoginStep = .verification
            }
            
        } catch {
            await MainActor.run {
                authError = .registrationFailed
                loginAnimation = .error
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func authenticateWithBiometrics() async {
        guard biometricType != .none else {
            authError = .biometricNotAvailable
            return
        }
        
        showingBiometricPrompt = true
        loginAnimation = .authenticating
        
        do {
            let result = try await biometricAuth.authenticate(reason: "Sign in to FinanceApp")
            
            if result {
                // Load stored user data
                if let storedUser = await loadUserFromSecureStorage() {
                    await MainActor.run {
                        currentUser = storedUser
                        authenticationState = .authenticated
                        isAuthenticated = true
                        loginAnimation = .success
                        showingBiometricPrompt = false
                    }
                }
            } else {
                await MainActor.run {
                    authError = .biometricFailed
                    loginAnimation = .error
                    showingBiometricPrompt = false
                }
            }
        } catch {
            await MainActor.run {
                authError = .biometricError(error.localizedDescription)
                loginAnimation = .error
                showingBiometricPrompt = false
            }
        }
    }
    
    public func signInWithApple() async {
        // Apple Sign In implementation
        loginAnimation = .authenticating
        isLoading = true
        
        // Simulate Apple Sign In flow
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            loginAnimation = .success
            isLoading = false
            // Set authenticated state
        }
    }
    
    public func signOut() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isAuthenticated = false
            currentUser = nil
            authenticationState = .unauthenticated
            currentLoginStep = .welcome
            loginAnimation = .idle
            
            // Clear form
            clearForm()
        }
        
        // Clear stored credentials
        Task {
            await keychain.deleteStoredCredentials()
        }
    }
    
    public func enableBiometric() async {
        do {
            let result = try await biometricAuth.authenticate(reason: "Enable biometric authentication for faster sign-in")
            
            if result {
                isBiometricEnabled = true
                biometricEnrollmentStep = .success
                
                // Store biometric preference
                UserDefaults.standard.set(true, forKey: "biometric_enabled")
            } else {
                authError = .biometricEnrollmentFailed
                biometricEnrollmentStep = .error
            }
        } catch {
            authError = .biometricError(error.localizedDescription)
            biometricEnrollmentStep = .error
        }
    }
    
    // MARK: - Navigation Methods
    public func moveToStep(_ step: LoginStep) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentLoginStep = step
            loginAnimation = .transition
        }
    }
    
    public func goBack() {
        let previousStep: LoginStep = switch currentLoginStep {
        case .signIn: .welcome
        case .signUp: .welcome
        case .forgotPassword: .signIn
        case .verification: .signUp
        case .biometricSetup: .success
        default: .welcome
        }
        
        moveToStep(previousStep)
    }
    
    // MARK: - Form Management
    public func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
        authError = nil
    }
    
    // MARK: - Private Methods
    private func setupKeyboardObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .sink { [weak self] height in
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.keyboardHeight = height
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.keyboardHeight = 0
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupFormValidation() {
        $email
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { $0.isValidEmail }
            .assign(to: &$isEmailValid)
        
        $password
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { $0.isValidPassword }
            .assign(to: &$isPasswordValid)
    }
    
    private func checkBiometricAvailability() {
        Task {
            let type = await biometricAuth.getBiometricType()
            await MainActor.run {
                biometricType = type
                isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled") && type != .none
            }
        }
    }
    
    private func loadStoredCredentials() {
        Task {
            if let credentials = await keychain.getStoredCredentials() {
                await MainActor.run {
                    email = credentials.email
                }
            }
        }
    }
    
    private func loadUserFromSecureStorage() async -> AuthUser? {
        // In real implementation, load from secure storage or make API call
        return AuthUser(
            id: UUID(),
            email: email,
            firstName: "User",
            lastName: "",
            isVerified: true,
            lastLoginDate: Date(),
            securityLevel: .high
        )
    }
}

// MARK: - Authentication Models
public struct AuthUser: Identifiable, Codable, Sendable {
    public let id: UUID
    public var email: String
    public var firstName: String
    public var lastName: String
    public var profileImageURL: String?
    public var isVerified: Bool
    public var lastLoginDate: Date
    public var securityLevel: SecurityLevel
    public var preferredAuthMethod: AuthenticationMethod
    public var accountCreatedDate: Date
    
    public var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    public var initials: String {
        let first = firstName.prefix(1).uppercased()
        let last = lastName.prefix(1).uppercased()
        return "\(first)\(last)"
    }
    
    public init(
        id: UUID,
        email: String,
        firstName: String,
        lastName: String,
        profileImageURL: String? = nil,
        isVerified: Bool = false,
        lastLoginDate: Date = Date(),
        securityLevel: SecurityLevel = .medium,
        preferredAuthMethod: AuthenticationMethod = .password
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageURL = profileImageURL
        self.isVerified = isVerified
        self.lastLoginDate = lastLoginDate
        self.securityLevel = securityLevel
        self.preferredAuthMethod = preferredAuthMethod
        self.accountCreatedDate = Date()
    }
}

// MARK: - Supporting Enums
public enum AuthenticationState: Sendable {
    case unauthenticated
    case authenticating
    case authenticated
    case needsVerification
    case locked
    case error(AuthError)
}

public enum LoginStep: CaseIterable, Sendable {
    case welcome
    case signIn
    case signUp
    case forgotPassword
    case verification
    case biometricSetup
    case success
    
    public var title: String {
        switch self {
        case .welcome: return "Welcome to FinanceApp"
        case .signIn: return "Sign In"
        case .signUp: return "Create Account"
        case .forgotPassword: return "Reset Password"
        case .verification: return "Verify Email"
        case .biometricSetup: return "Security Setup"
        case .success: return "Welcome!"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .welcome: return "Your complete financial life, simplified"
        case .signIn: return "Sign in to your account"
        case .signUp: return "Join thousands of smart investors"
        case .forgotPassword: return "We'll send you a reset link"
        case .verification: return "Check your email for verification"
        case .biometricSetup: return "Secure your account with biometrics"
        case .success: return "Your financial journey starts now"
        }
    }
}

public enum LoginAnimationPhase: Sendable {
    case idle
    case transition
    case authenticating
    case success
    case error
}

public enum BiometricType: Sendable {
    case none
    case touchID
    case faceID
    case opticID
    
    public var displayName: String {
        switch self {
        case .none: return "None"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .opticID: return "Optic ID"
        }
    }
    
    public var iconName: String {
        switch self {
        case .none: return "lock"
        case .touchID: return "touchid"
        case .faceID: return "faceid"
        case .opticID: return "opticid"
        }
    }
    
    public var authMethod: AuthenticationMethod {
        switch self {
        case .none: return .password
        case .touchID: return .touchID
        case .faceID: return .faceID
        case .opticID: return .opticID
        }
    }
}

public enum AuthenticationMethod: String, CaseIterable, Codable, Sendable {
    case password = "password"
    case touchID = "touchID"
    case faceID = "faceID"
    case opticID = "opticID"
    case appleID = "appleID"
    
    public var displayName: String {
        switch self {
        case .password: return "Password"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .opticID: return "Optic ID"
        case .appleID: return "Apple ID"
        }
    }
}

public enum SecurityLevel: String, CaseIterable, Codable, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case maximum = "maximum"
    
    public var displayName: String {
        return rawValue.capitalized
    }
    
    public var color: Color {
        switch self {
        case .low: return .red
        case .medium: return .orange
        case .high: return .green
        case .maximum: return .blue
        }
    }
    
    public var description: String {
        switch self {
        case .low: return "Basic security measures"
        case .medium: return "Standard security with email verification"
        case .high: return "Enhanced security with biometric authentication"
        case .maximum: return "Maximum security with multi-factor authentication"
        }
    }
}

public enum BiometricEnrollmentStep: Sendable {
    case prompt
    case authenticating
    case success
    case error
    case declined
}

public enum AuthError: Error, Identifiable, Sendable {
    case invalidCredentials
    case invalidInput
    case networkError
    case registrationFailed
    case biometricNotAvailable
    case biometricFailed
    case biometricEnrollmentFailed
    case biometricError(String)
    case accountLocked
    case emailNotVerified
    case serverError
    case unknown
    
    public var id: String {
        switch self {
        case .invalidCredentials: return "invalidCredentials"
        case .invalidInput: return "invalidInput"
        case .networkError: return "networkError"
        case .registrationFailed: return "registrationFailed"
        case .biometricNotAvailable: return "biometricNotAvailable"
        case .biometricFailed: return "biometricFailed"
        case .biometricEnrollmentFailed: return "biometricEnrollmentFailed"
        case .biometricError: return "biometricError"
        case .accountLocked: return "accountLocked"
        case .emailNotVerified: return "emailNotVerified"
        case .serverError: return "serverError"
        case .unknown: return "unknown"
        }
    }
    
    public var title: String {
        switch self {
        case .invalidCredentials: return "Invalid Credentials"
        case .invalidInput: return "Invalid Input"
        case .networkError: return "Network Error"
        case .registrationFailed: return "Registration Failed"
        case .biometricNotAvailable: return "Biometric Unavailable"
        case .biometricFailed: return "Biometric Authentication Failed"
        case .biometricEnrollmentFailed: return "Biometric Setup Failed"
        case .biometricError: return "Biometric Error"
        case .accountLocked: return "Account Locked"
        case .emailNotVerified: return "Email Not Verified"
        case .serverError: return "Server Error"
        case .unknown: return "Unknown Error"
        }
    }
    
    public var message: String {
        switch self {
        case .invalidCredentials:
            return "Please check your email and password and try again."
        case .invalidInput:
            return "Please ensure all fields are filled out correctly."
        case .networkError:
            return "Please check your internet connection and try again."
        case .registrationFailed:
            return "Unable to create account. Please try again later."
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device."
        case .biometricFailed:
            return "Biometric authentication failed. Please try again or use password."
        case .biometricEnrollmentFailed:
            return "Unable to setup biometric authentication. Please try again."
        case .biometricError(let error):
            return "Biometric error: \(error)"
        case .accountLocked:
            return "Your account has been locked. Please contact support."
        case .emailNotVerified:
            return "Please verify your email address before signing in."
        case .serverError:
            return "Server error occurred. Please try again later."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    public var recoveryAction: String? {
        switch self {
        case .invalidCredentials: return "Forgot Password?"
        case .networkError: return "Retry"
        case .biometricFailed: return "Use Password Instead"
        case .emailNotVerified: return "Resend Verification"
        default: return nil
        }
    }
}

// MARK: - Support Managers
public actor KeychainManager {
    public func storeCredentials(email: String, password: String) async throws {
        // Implementation for storing credentials in Keychain
    }
    
    public func getStoredCredentials() async -> (email: String, password: String)? {
        // Implementation for retrieving stored credentials
        return nil
    }
    
    public func deleteStoredCredentials() async {
        // Implementation for deleting stored credentials
    }
}

public actor BiometricAuthManager {
    private let context = LAContext()
    
    public func getBiometricType() async -> BiometricType {
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default: return .none
        }
    }
    
    public func authenticate(reason: String) async throws -> Bool {
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}

// MARK: - Extensions
extension String {
    public var isValidEmail: Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self) && count >= 5
    }
    
    public var isValidPassword: Bool {
        return count >= 8 && 
               contains(where: { $0.isUppercase }) &&
               contains(where: { $0.isLowercase }) &&
               contains(where: { $0.isNumber })
    }
}

#if DEBUG
struct AuthenticationManager_Previews: PreviewProvider {
    static var previews: some View {
        Text("Authentication Manager")
            .environmentObject(AuthenticationManager())
    }
}
#endif

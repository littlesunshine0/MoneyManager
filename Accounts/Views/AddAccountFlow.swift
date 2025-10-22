import SwiftUI
import SwiftData
import Combine

// MARK: - Add Account Flow
public struct AddAccountView: View {
    @StateObject private var viewModel = AddAccountViewModel()
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var accessibilityManager: AccessibilitySystem.AccessibilityManager
    
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Indicator
                    AddAccountProgressView(currentStep: viewModel.currentStep)
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                        .padding(.top, DesignTokens.Spacing.md)
                    
                    // Step Content
                    TabView(selection: $viewModel.currentStep) {
                        ForEach(AddAccountStep.allCases, id: \.self) { step in
                            stepView(for: step)
                                .tag(step)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
                    
                    // Navigation Buttons
                    AddAccountNavigationButtons(viewModel: viewModel) {
                        // Complete account creation
                        Task { @MainActor in
                            await completeAccountCreation()
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.xl)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.textColorSecondary)
                }
            }
        }
        .overlay {
            if viewModel.isProcessing {
                AddAccountProcessingOverlay()
            }
        }
    }
    
    @ViewBuilder
    private func stepView(for step: AddAccountStep) -> some View {
        switch step {
        case .accountType:
            AccountTypeSelectionView()
                .environmentObject(viewModel)
        case .accountDetails:
            AccountDetailsEntryView()
                .environmentObject(viewModel)
        case .bankConnection:
            BankConnectionView()
                .environmentObject(viewModel)
        case .verification:
            AccountVerificationView()
                .environmentObject(viewModel)
        }
    }
    
    @MainActor
    private func completeAccountCreation() async {
        viewModel.isProcessing = true
        
        guard let selectedType = viewModel.selectedAccountType else {
            viewModel.isProcessing = false
            return
        }
        
        // Create the new account
        let newAccount = Account(
            name: viewModel.accountName,
            accountType: selectedType,
            balance: viewModel.initialBalance,
            currency: viewModel.selectedCurrency,
            accountNumber: viewModel.accountNumber.isEmpty ? nil : viewModel.accountNumber,
            institutionName: viewModel.institutionName.isEmpty ? nil : viewModel.institutionName,
            color: selectedType.defaultColor
        )
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Add to accounts list
        await accountsViewModel.addAccount(newAccount)
        
        viewModel.isProcessing = false
        
        // Provide success feedback using the new granular event API
        accessibilityManager.provideTactileFeedback(for: .success)
        
        dismiss()
    }
}

// MARK: - Add Account View Model
@MainActor
public class AddAccountViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentStep: AddAccountStep = .accountType
    @Published public var selectedAccountType: AccountType?
    @Published public var accountName = ""
    @Published public var institutionName = ""
    @Published public var accountNumber = ""
    @Published public var routingNumber = ""
    @Published public var initialBalance: Double = 0.0
    @Published public var selectedCurrency = "USD"
    @Published public var connectionMethod: ConnectionMethod = .manual
    @Published public var isProcessing = false
    
    // MARK: - Computed Properties
    public var progress: Double {
        let totalSteps = AddAccountStep.allCases.count
        let currentIndex = AddAccountStep.allCases.firstIndex(of: currentStep) ?? 0
        return Double(currentIndex) / Double(totalSteps - 1)
    }
    
    public var canProceed: Bool {
        switch currentStep {
        case .accountType:
            return selectedAccountType != nil
        case .accountDetails:
            return !accountName.isEmpty && !institutionName.isEmpty
        case .bankConnection:
            return connectionMethod == .manual || !accountNumber.isEmpty
        case .verification:
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
}

// MARK: - Add Account Steps
public enum AddAccountStep: String, CaseIterable {
    case accountType = "type"
    case accountDetails = "details"
    case bankConnection = "connection"
    case verification = "verification"
    
    public var title: String {
        switch self {
        case .accountType: return "Account Type"
        case .accountDetails: return "Account Details"
        case .bankConnection: return "Connection"
        case .verification: return "Verification"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .accountType: return "What type of account would you like to add?"
        case .accountDetails: return "Tell us about your account"
        case .bankConnection: return "How would you like to connect this account?"
        case .verification: return "Review and confirm your account details"
        }
    }
    
    public var nextStep: AddAccountStep? {
        let allCases = AddAccountStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex < allCases.count - 1 else { return nil }
        return allCases[currentIndex + 1]
    }
    
    public var previousStep: AddAccountStep? {
        let allCases = AddAccountStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex > 0 else { return nil }
        return allCases[currentIndex - 1]
    }
}

public enum ConnectionMethod: String, CaseIterable {
    case manual = "manual"
    case bankLogin = "bank_login"
    case fileImport = "file_import"
    
    public var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .bankLogin: return "Bank Login"
        case .fileImport: return "Import File"
        }
    }
    
    public var description: String {
        switch self {
        case .manual: return "Enter account details manually"
        case .bankLogin: return "Connect securely with your online banking"
        case .fileImport: return "Import from bank statement or CSV file"
        }
    }
    
    public var iconName: String {
        switch self {
        case .manual: return "pencil.circle"
        case .bankLogin: return "building.columns.circle"
        case .fileImport: return "doc.circle"
        }
    }
}

// MARK: - Progress View
private struct AddAccountProgressView: View {
    let currentStep: AddAccountStep
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let steps = AddAccountStep.allCases
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Step Indicators
            HStack {
                ForEach(Array(steps.enumerated()), id: \.1) { index, step in
                    HStack {
                        // Step Circle
                        Circle()
                            .fill(stepColor(for: step))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Group {
                                    if isStepCompleted(step) {
                                        Icon("checkmark", context: .status, color: Color.white)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                        
                        // Connector Line
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(isStepCompleted(step) ?
                                      themeManager.currentTheme.primaryColor :
                                      themeManager.currentTheme.borderColor)
                                .frame(height: 2)
                                .animation(.easeInOut(duration: 0.3), value: currentStep)
                        }
                    }
                }
            }
            
            // Step Title
            Text(currentStep.title)
                .font(Typography.TextStyle.titleLarge)
                .foregroundColor(themeManager.currentTheme.textColorPrimary)
                .animation(.easeInOut, value: currentStep)
            
            Text(currentStep.subtitle)
                .font(Typography.TextStyle.bodyMedium)
                .foregroundColor(themeManager.currentTheme.textColorSecondary)
                .multilineTextAlignment(.center)
                .animation(.easeInOut, value: currentStep)
        }
    }
    
    private func stepColor(for step: AddAccountStep) -> Color {
        if step == currentStep {
            return themeManager.currentTheme.primaryColor
        } else if isStepCompleted(step) {
            return themeManager.currentTheme.primaryColor
        } else {
            return themeManager.currentTheme.borderColor
        }
    }
    
    private func isStepCompleted(_ step: AddAccountStep) -> Bool {
        guard let currentIndex = steps.firstIndex(of: currentStep),
              let stepIndex = steps.firstIndex(of: step) else { return false }
        return stepIndex < currentIndex
    }
}

// MARK: - Account Type Selection View
private struct AccountTypeSelectionView: View {
    @EnvironmentObject private var viewModel: AddAccountViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                
                Spacer()
                    .frame(height: DesignTokens.Spacing.lg)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignTokens.Spacing.md) {
                    ForEach(Array(AccountType.allCases.enumerated()), id: \.1) { index, accountType in
                        AccountTypeCard(
                            accountType: accountType,
                            isSelected: viewModel.selectedAccountType == accountType
                        ) {
                            viewModel.selectedAccountType = accountType
                        }
                        .fadeInScale(delay: Double(index) * 0.1)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                Spacer()
            }
        }
    }
}

// The remainder of this file stays unchanged…

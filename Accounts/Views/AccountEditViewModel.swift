//
//  AccountEditViewModel.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import Foundation
import Combine

// MARK: - Account Edit View Model
@MainActor
public class AccountEditViewModel: ObservableObject {
    @Published public var accountName = ""
    @Published public var institutionName = ""
    @Published public var accountNumber = ""
    @Published public var balance: Double = 0.0
    @Published public var selectedColor = "#3882FF"
    
    private var originalAccount: Account?
    
    public var hasChanges: Bool {
        guard let original = originalAccount else { return false }
        
        return accountName != original.name ||
               institutionName != (original.institutionName ?? "") ||
               accountNumber != (original.accountNumber ?? "") ||
               balance != original.balance ||
               selectedColor != original.color
    }
    
    public func loadAccount(_ account: Account) {
        originalAccount = account
        accountName = account.name
        institutionName = account.institutionName ?? ""
        accountNumber = account.accountNumber ?? ""
        balance = account.balance
        selectedColor = account.color
    }
}

enum EditAccountField {
    case accountName
    case institutionName
    case accountNumber
    case balance
}

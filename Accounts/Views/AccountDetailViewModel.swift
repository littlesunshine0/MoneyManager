//
//  AccountDetailViewModel.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/17/25.
//

import Foundation
import Combine

// MARK: - Account Detail View Model
@MainActor
public class AccountDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var recentTransactions: [Transaction] = []
    @Published public var accountBalance: Double = 0.0
    @Published public var monthlyIncome: Double = 0.0
    @Published public var monthlyExpenses: Double = 0.0
    @Published public var isLoading = false
    
    // MARK: - Methods
    public func loadAccountData(for account: Account) async {
        isLoading = true
        
        // Simulate loading
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // In real app, fetch from SwiftData
        recentTransactions = createSampleTransactions()
        accountBalance = account.balance
        calculateMonthlyStats()
        
        isLoading = false
    }
    
    public func refreshAccountData(for account: Account) async {
        // Refresh account data
        await loadAccountData(for: account)
    }
    
    private func calculateMonthlyStats() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let thisMonthTransactions = recentTransactions.filter { $0.date >= startOfMonth }
        
        monthlyIncome = thisMonthTransactions
            .filter { !$0.type.isExpense }
            .reduce(0) { $0 + $1.amount }
        
        monthlyExpenses = thisMonthTransactions
            .filter { $0.type.isExpense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func createSampleTransactions() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            Transaction(amount: 3200.00, description: "Salary Deposit", date: calendar.date(byAdding: .day, value: -1, to: now) ?? now, type: .income),
            Transaction(amount: 4.75, description: "Coffee Shop", date: calendar.date(byAdding: .hour, value: -3, to: now) ?? now, type: .expense),
            Transaction(amount: 87.50, description: "Grocery Store", date: calendar.date(byAdding: .day, value: -2, to: now) ?? now, type: .expense),
            Transaction(amount: 45.00, description: "Gas Station", date: calendar.date(byAdding: .day, value: -3, to: now) ?? now, type: .expense),
            Transaction(amount: 500.00, description: "Transfer to Savings", date: calendar.date(byAdding: .day, value: -4, to: now) ?? now, type: .transfer),
            Transaction(amount: 25.99, description: "Netflix Subscription", date: calendar.date(byAdding: .day, value: -5, to: now) ?? now, type: .expense),
            Transaction(amount: 1200.00, description: "Rent Payment", date: calendar.date(byAdding: .day, value: -7, to: now) ?? now, type: .expense)
        ]
    }
}

//
//  User.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 06/07/2025.
//


final class User: Codable, Sendable {
    private let id: Int?
    private let email: String
    private let password: String?
    private let expenses: [Expense]?
    private let incomes: [Income]?
    private let recurringCharges: [RecurringCharge]?
    private let recurringRevenues: [RecurringRevenue]?
    
    
    init(userId: Int? = nil, email: String, password: String? = nil, expenses: [Expense]? = nil, incomes: [Income]? = nil, recurringCharges: [RecurringCharge]? = nil, recurringRevenue: [RecurringRevenue]? = nil) {
        self.id = userId
        self.email = email
        self.password = password
        self.expenses = expenses
        self.incomes = incomes
        self.recurringCharges = recurringCharges
        self.recurringRevenues = recurringRevenue
    }
    
    public func getEmail() -> String {
        return self.email
    }
}

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
    private let transactions: [Transaction]
    
    
    init(id: Int? = nil, email: String, password: String?, transactions: [Transaction] = []) {
        self.id = id
        self.email = email
        self.password = password
        self.transactions = transactions
    }
    
    public func getEmail() -> String {
        return self.email
    }
}

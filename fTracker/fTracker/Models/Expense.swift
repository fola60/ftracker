//
//  Expense.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//

class ExpenseResponse: Decodable {
    let results: Array<Expense>
}

class Expense: Decodable, Encodable {
    var type: String
    var amount: Double
    var name: String
    var description: String
    var userId: Int
    
    init(type: String, amount: Double, name: String, description: String, userId: Int) {
        self.type = type
        self.amount = amount
        self.name = name
        self.description = description
        self.userId = userId
    }
    
}




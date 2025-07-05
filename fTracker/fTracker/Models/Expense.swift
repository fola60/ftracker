//
//  Expense.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//

import Foundation

class ExpenseResponse: Decodable {
    let results: Array<Expense>
}

class Expenses: ObservableObject {
    @Published var results: Array<Expense> = []
    
    init(responses: ExpenseListResponse) {
        for i in 0..<responses.cost.count {
            let expense = Expense(
                type: responses.expense_type[safe: i] ?? "OTHER",
                amount: responses.cost[safe: i] ?? 0.00,
                name: responses.name[safe: i] ?? "",
                description: responses.description[safe: i] ?? ""
            )
            
            results.append(expense)
        }
    }
    
    init() {
        
    }
}


class Expense: Decodable, Encodable, ObservableObject, Identifiable {
    let type: String
    let amount: Double
    let name: String
    let description: String
    let id: Int?
    let time: Date?
    
    init(type: String, amount: Double, name: String, description: String, id: Int? = nil, time: String? = nil) {
        self.type = type
        self.amount = amount
        self.name = name
        self.description = description
        self.id = id
        if let time = time {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.time = formatter.date(from: time)
        } else {
            self.time = nil
        }
    }
    
    
    
}






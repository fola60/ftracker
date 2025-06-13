//
//  Income.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
class IncomeResponse: Decodable {
    let results: Array<Income>
}

class Income: Decodable, Encodable {
    let type: String
    let amount: Double
    let name: String
    let description: String
    let user_id: Int
    
    init(type: String, amount: Double, name: String, description: String, user_id: Int) {
        self.type = type
        self.amount = amount
        self.name = name
        self.description = description
        self.user_id = user_id
    }
}

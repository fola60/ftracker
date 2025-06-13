//
//  RecurringRevenue.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//

class RecurringRevenueResponse: Decodable {
    let results: Array<RecurringRevenue>
}

class RecurringRevenue: Decodable, Encodable {
    let type: String
    let timeRecurring: Int
    let amount: Double
    let name: String
    let description: String
    let userId: Int
    
    init(type: String, timeRecurring: Int, amount: Double, name: String, description: String, userId: Int) {
        self.type = type
        self.timeRecurring = timeRecurring
        self.amount = amount
        self.name = name
        self.description = description
        self.userId = userId
    }
}

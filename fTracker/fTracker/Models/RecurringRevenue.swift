//
//  RecurringRevenue.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

class RecurringRevenueResponse: Decodable {
    let results: Array<RecurringRevenue>
}

class RecurringRevenues: ObservableObject {
    @Published var results: Array<RecurringRevenue> = []
    
    init(responses: RecurringRevenueListResponse) {
        for i in 0..<responses.amount.count {
            let recurringRevenue = RecurringRevenue(
                type: responses.type[safe:i] ?? "OTHER",
                time_recurring: responses.time_recurring[safe: i] ?? 30,
                amount: responses.amount[safe: i] ?? 0.00,
                name: responses.name[safe: i] ?? "",
                description: responses.description[safe: i] ?? ""
            )
            
            results.append(recurringRevenue)
        }
    }
    
    init() {
        
    }
}


final class RecurringRevenue: Decodable, Encodable, ObservableObject, Identifiable, Sendable {
    let type: String
    let time_recurring: Int
    let amount: Double
    let name: String
    let description: String
    
    
    init(type: String, time_recurring: Int, amount: Double, name: String, description: String) {
        self.type = type
        self.time_recurring = time_recurring
        self.amount = amount
        self.name = name
        self.description = description
        
    }
}

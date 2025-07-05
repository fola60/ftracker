//
//  RecurringCharge.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

class RecurringChargeResponse: Decodable {
    let results: Array<RecurringCharge>
}

class RecurringCharges: ObservableObject {
    @Published var results: Array<RecurringCharge> = []
    
    init(responses: RecurringChargeListResponse) {
        for i in 0..<responses.cost.count {
            let recurringCharge = RecurringCharge(
                type: responses.type[safe: i] ?? "OTHER",
                recurring_type: responses.recurring_type[safe: i] ?? "OTHER",
                time_recurring: responses.time_recurring[safe: i] ?? 30,
                amount: responses.cost[safe: i] ?? 0.00,
                name: responses.name[safe: i] ?? "",
                description: responses.description[safe: i] ?? ""
            )
            
            results.append(recurringCharge)
        }
    }
    
    init() {
        
    }
}



class RecurringCharge: Decodable, Encodable, ObservableObject, Identifiable {
    let type: String
    let recurring_type: String
    let time_recurring: Int
    let amount: Double
    let name: String
    let description: String
    let id: Int?
    
    
    init(type: String, recurring_type: String, time_recurring: Int, amount: Double, name: String, description: String, id: Int? = nil) {
        self.type = type
        self.recurring_type = recurring_type
        self.time_recurring = time_recurring
        self.amount = amount
        self.name = name
        self.description = description
        self.id = id
    }
}

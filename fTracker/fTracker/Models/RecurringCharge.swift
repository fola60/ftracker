//
//  RecurringCharge.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//

class RecurringChargeResponse: Decodable {
    let results: Array<RecurringCharge>
}

class RecurringCharge: Decodable, Encodable {
    let type: String
    let recurringType: String
    let timeRecurring: Int
    let amount: Double
    let name: String
    let description: String
    let userId: Int
    
    init(type: String, recurringType: String, timeRecurring: Int, amount: Double, name: String, description: String, userId: Int) {
        self.type = type
        self.recurringType = recurringType
        self.timeRecurring = timeRecurring
        self.amount = amount
        self.name = name
        self.description = description
        self.userId = userId
    }
}

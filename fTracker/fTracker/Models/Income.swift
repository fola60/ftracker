//
//  Income.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

class IncomeResponse: Decodable {
    let results: Array<Income>
}


class Incomes: ObservableObject {
    @Published var results: Array<Income> = []

    init(responses: IncomeListResponse) {
        for index in 0..<responses.amount.count {
            let income = Income(
                type: responses.income_type[safe: index] ?? "OTHER",
                amount: responses.amount[safe: index] ?? 0.0,
                name: responses.name[safe: index] ?? "",
                description: responses.description[safe: index] ?? ""
            )
            results.append(income)
        }
    }
    
    init() {
        
    }
}


extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


final class Income: Decodable, Encodable, ObservableObject, Identifiable, Sendable {
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

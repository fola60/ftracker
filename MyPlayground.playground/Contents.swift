import UIKit
import Foundation

var greeting = "Hello, playground"

class ExpenseResponse: Decodable {
    let results: Array<Expense>
}

class Expenses: ObservableObject {
    var results: Array<Expense> = []
    
    
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

do {
    let url = URL(string: "http://localhost:8080/expense/get-expense-by-user-id/1")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    decoder.dateDecodingStrategy = .formatted(formatter)
    let decoded = try decoder.decode([Expense].self, from: data)
    
    let calendar = Calendar.current
    if let time = decoded[0].time {
        let day = Calendar.current.component(.day, from: time)
        print(day)
    }
    dump(decoded[0])
} catch {
    print(error)
}

    

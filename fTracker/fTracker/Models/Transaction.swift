import Foundation

enum TransactionType: String, Codable {
    case income = "INCOME"
    case expense = "EXPENSE"
    case recurring_expense = "RECURRING_EXPENSE"
    case recurring_income = "RECURRING_INCOME"
}

final class Transaction:  Codable, ObservableObject, Identifiable, Sendable {
    let id: Int?
    let category: Category
    let time: Date?
    let amount: Float
    let name: String
    let description: String
    let transactionType: TransactionType
    let time_recurring: Int?
    
    
    init(id: Int?, category: Category, time: String?, amount: Float, name: String, description: String, transactionType: TransactionType, time_recurring: Int?) {
        self.id = id
        self.category = category
        self.amount = amount
        self.name = name
        self.description = description
        self.transactionType = transactionType
        self.time_recurring = time_recurring
        if let time = time {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.time = formatter.date(from: time)
        } else {
            self.time = nil
        }
    }
}

final class TransactionRequest: Codable, ObservableObject, Identifiable, Sendable {
    let id: Int?
    let category_id: Int
    let time: String?
    let amount: Float
    let name: String
    let description: String
    let transaction_type: TransactionType
    let time_recurring: Int?
    let user_id: Int
    
    init(id: Int? = nil, category_id: Int, time: Date?, amount: Float, name: String, description: String, transaction_type: TransactionType, time_recurring: Int?, user_id: Int) {
        self.id = id
        self.category_id = category_id
        
        if let time = time {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.time = formatter.string(from: time)
        } else {
            self.time = nil
        }
        self.amount = amount
        self.name = name
        self.description = description
        self.transaction_type = transaction_type
        self.time_recurring = time_recurring
        self.user_id = user_id
    }
}

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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.amount = try container.decode(Float.self, forKey: .amount)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.transactionType = try container.decode(TransactionType.self, forKey: .transactionType)
        self.time_recurring = try container.decodeIfPresent(Int.self, forKey: .time_recurring)

        
        if let decodedCategory = try container.decodeIfPresent(Category.self, forKey: .category) {
            self.category = decodedCategory
        } else {
            self.category = Category(id: nil, headCategory: .miscellaneous, name: "Miscellaneous")
        }

        
        if let timeString = try container.decodeIfPresent(String.self, forKey: .time) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.time = formatter.date(from: timeString)
        } else {
            self.time = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case category
        case time
        case amount
        case name
        case description
        case transactionType
        case time_recurring
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

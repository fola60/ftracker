import Foundation

enum HeadCategoryType: String, Codable {
    case entertainment = "ENTERTAINMENT"
    case food_and_drinks = "FOOD_AND_DRINKS"
    case housing = "HOUSING"
    case income = "INCOME"
    case lifestyle = "LIFESTYLE"
    case miscellaneous = "MISCELLANEOUS"
    case savings = "SAVINGS"
    case transportation = "TRANSPORTATION"
}

final class Category: Codable, ObservableObject, Identifiable, Sendable {
    let id: Int?
    let headCategory: HeadCategoryType
    let name: String
    
    init(id: Int?, headCategory: HeadCategoryType, name: String) {
        self.id = id
        self.headCategory = headCategory
        self.name = name
    }
}

final class CategoryRequest: Codable, ObservableObject, Identifiable, Sendable {
    let id: Int?
    let head_category: HeadCategoryType
    let name: String
    let user_id: Int
    
    init(id: Int?, head_category: HeadCategoryType, name: String, user_id: Int) {
        self.id = id
        self.head_category = head_category
        self.name = name
        self.user_id = user_id
    }
}

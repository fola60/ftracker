import Foundation

final class BudgetCategory: Codable, ObservableObject, Identifiable, Sendable {
    let id: Int
    let categoryId: Category
    let budgetAmount: Float
    
    init(id: Int, categoryId: Category, amount: Float) {
        self.id = id
        self.categoryId = categoryId
        self.budgetAmount = amount
    }
}

final class BudgetCategoryRequest: Codable, ObservableObject, Identifiable, Sendable {
    let id: Int?
    let budget_id: Int?
    let amount: Float
    let category_id: Int
    
    init(id: Int?, budget_id: Int?, amount: Float, category_id: Int) {
        self.id = id
        self.budget_id = budget_id
        self.amount = amount
        self.category_id = category_id
    }
}

final class Budget: Codable, ObservableObject, Identifiable, Sendable {
    let id: Int?
    let budgetCategories: [BudgetCategory]
    let name: String
    
    init(id: Int?, budgetCategories: [BudgetCategory], name: String) {
        self.id = id
        self.budgetCategories = budgetCategories
        self.name = name
    }
}


final class BudgetRequest: Codable, ObservableObject, Identifiable, Sendable {
    let id: Int?
    let name: String
    let user_id: Int
    
    init(id: Int?, name: String, user_id: Int) {
        self.id = id
        self.name = name
        self.user_id = user_id
    }
    
}

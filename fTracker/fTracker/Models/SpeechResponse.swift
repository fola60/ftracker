//
//  SpeechResponse.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 22/06/2025.
//
import Foundation

struct SpeechResponse: Codable {
    var success: Bool
    var error_message: String?
    var type: ItemType
    var action: String?
    var transaction_id: Int?
    var transaction: [Transaction]?
    var budgets: [Budget]?
    var action_type: ActionType?
    
    init(success: Bool, error_message: String? = nil, type: ItemType, action: String? = nil, transaction_id: Int? = nil, transaction: [Transaction]? = nil, budgets: [Budget], action_type: ActionType? = nil) {
        self.success = success
        self.error_message = error_message
        self.type = type
        self.action = action
        self.transaction_id = transaction_id
        self.transaction = transaction
        self.budgets = budgets
        self.action_type = action_type
    }
}

enum ItemType: String, Codable {
    case BUDGET = "BUDGET"
    case TRANSACTION = "TRANSACTION"
    case INFO = "INFO"
    case ERROR = "ERROR"
}

enum ActionType: String, Codable {
    case CREATE = "CREATE"
    case READ = "READ"
    case UPDATE = "UPDATE"
    case DELETE = "DELETE"
    case NONE = "NONE"
}



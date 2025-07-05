//
//  SpeechResponse.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 22/06/2025.
//
import Foundation

struct SpeechResponse: Codable {
    var success: Bool
    var error_message: String
    var type: ItemType
    var expense: ExpenseListResponse?
    var income: IncomeListResponse?
    var recurringCharge: RecurringChargeListResponse?
    var recurringRevenue: RecurringRevenueListResponse?
    
}

enum ItemType: String, Codable {
    case income = "INCOME"
    case expense = "EXPENSE"
    case recurring_charge = "RECURRING_CHARGE"
    case recurring_revenue = "RECURRING_REVENUE"
    case error = "ERROR"
}

struct ExpenseListResponse: Codable {
    var expense_type: Array<String>
    var cost: Array<Double>
    var name: Array<String>
    var description: Array<String>
    
    
}

struct IncomeListResponse: Codable {
    var income_type: Array<String>
    var amount: Array<Double>
    var name: Array<String>
    var description: Array<String>
    
    
}

struct RecurringChargeListResponse: Codable {
    var time_recurring: Array<Int>
    var type: Array<String>
    var recurring_type: Array<String>
    var cost: Array<Double>
    var name: Array<String>
    var description: Array<String>
    
    
}

struct RecurringRevenueListResponse: Codable {
    var time_recurring: Array<Int>
    var type: Array<String>
    var amount: Array<Double>
    var name: Array<String>
    var description: Array<String>
    
    
}

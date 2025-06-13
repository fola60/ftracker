//
//  GET.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

func getExpenses(userId: Int) async throws -> Array<Expense> {
    
    let url = URL(string: "http://localhost/expense/get-expense-by-user-id/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoded = try JSONDecoder().decode(ExpenseResponse.self, from: data)
    
    return decoded.results;
}

func getIncomes(userId: Int) async throws -> Array<Income> {
    let url = URL(string: "http://localhost/income/get-income-by-user-id/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoded = try JSONDecoder().decode(IncomeResponse.self, from: data)
    
    return decoded.results;
}

func getRecurringCharges(userId: Int) async throws -> Array<RecurringCharge> {
    let url = URL(string: "http://localhost/recurring-charges/get-recurring-charge/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoded = try JSONDecoder().decode(RecurringChargeResponse.self, from: data)
    
    return decoded.results;
}

func getRecurringRevenues(userId: Int) async throws -> Array<RecurringRevenue> {
    let url = URL(string: "http://localhost/recurring-revenues/get-recurring-revenue/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoded = try JSONDecoder().decode(RecurringRevenueResponse.self, from: data)
    
    return decoded.results;
}

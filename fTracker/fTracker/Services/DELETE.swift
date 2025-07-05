//
//  DELETE.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

func deleteExpense(_ expenseId: Int) async -> Bool {
    var request = URLRequest(url: URL(string: "http://localhost:8080/expense/delete-expense/\(expenseId)")!)
    request.httpMethod = "DELETE"
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            return (200...299).contains(httpResponse.statusCode)
        }
    } catch {
        print(error)
        return false
    }
    
    return false
}

func deleteIncome(_ incomeId: Int) async -> Bool {
    var request = URLRequest(url: URL(string: "http://localhost:8080/income/delete-income/\(incomeId)")!)
    request.httpMethod = "DELETE"
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            return (200...299).contains(httpResponse.statusCode)
        }
    } catch {
        print(error)
        return false
    }
    
    return false
}

func deleteRecurringCharge(_ recurringChargeId: Int) async -> Bool {
    var request = URLRequest(url: URL(string: "http://localhost:8080/recurring-charges/delete-recurring-charge/\(recurringChargeId)")!)
    request.httpMethod = "DELETE"
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            return (200...299).contains(httpResponse.statusCode)
        }
    } catch {
        print(error)
        return false
    }
    
    return false
}

func deleteRecurringRevenue(_ recurringRevenueId: Int) async  -> Bool {
    
    var request = URLRequest(url: URL(string: "http://localhost:8080/recurring-revenues/delete-recurring-revenue/\(recurringRevenueId)")!)
    request.httpMethod = "DELETE"
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            return (200...299).contains(httpResponse.statusCode)
        }
    } catch {
        print(error)
        return false
    }
    
    return false
}

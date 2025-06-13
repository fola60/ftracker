//
//  POST.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

func postExpense(expense: Expense) async -> Bool {
    let url = URL(string: "http://localhost/expense/post-expense")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let data = try! JSONEncoder().encode(expense)
    request.httpBody = data
    request.setValue(
        "application/json",
        forHTTPHeaderField: "Content-Type"
    )
    
    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        
        if statusCode == 200 {
            print("SUCCESS")
            print(responseData)
            return true
        } else {
            print("FAILURE Status code: \(statusCode)")
            return false
        }
    } catch {
        print("Network error: \(error)")
        return false
    }
    
}

func postIncome(income: Income) async -> Bool {
    let url = URL(string: "http://localhost/income/post-income")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let data = try! JSONEncoder().encode(income)
    request.httpBody = data
    request.setValue(
        "application/json",
        forHTTPHeaderField: "Content-Type"
    )
    
    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        
        if statusCode == 200 {
            print("SUCCESS")
            print(responseData)
            return true
        } else {
            print("FAILURE Status code: \(statusCode)")
            return false
        }
    } catch {
        print("Network error: \(error)")
        return false
    }}

func postRecurringCharge(recurringCharge: RecurringCharge) async -> Bool {
    let url = URL(string: "http://localhost/recurring-charges/post-recurring-charge")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let data = try! JSONEncoder().encode(recurringCharge)
    request.httpBody = data
    request.setValue(
        "application/json",
        forHTTPHeaderField: "Content-Type"
    )
    
    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        
        if statusCode == 200 {
            print("SUCCESS")
            print(responseData)
            return true
        } else {
            print("FAILURE Status code: \(statusCode)")
            return false
        }
    } catch {
        print("Network error: \(error)")
        return false
    }
}

func postRecurringRevenue(recurringRevenue: RecurringRevenue) async -> Bool {
    let url = URL(string: "http://localhost/recurring-revenues/post-recurring-revenue")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let data = try! JSONEncoder().encode(recurringRevenue)
    request.httpBody = data
    request.setValue(
        "application/json",
        forHTTPHeaderField: "Content-Type"
    )
    
    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        
        if statusCode == 200 {
            print("SUCCESS")
            print(responseData)
            return true
        } else {
            print("FAILURE Status code: \(statusCode)")
            return false
        }
    } catch {
        print("Network error: \(error)")
        return false
    }
}

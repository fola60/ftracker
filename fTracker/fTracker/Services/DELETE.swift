//
//  DELETE.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

func deleteTransaction(_ transactionId: Int) async -> Bool {
    var request = URLRequest(url: URL(string: "\(Globals.backendUrl)/transaction/delete/\(transactionId)")!)
    request.httpMethod = "DELETE"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")
    
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

func deleteCategory(_ categoryId: Int) async -> Bool {
    var request = URLRequest(url: URL(string: "\(Globals.backendUrl)/category/delete/\(categoryId)")!)
    request.httpMethod = "DELETE"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")
    
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

func deleteBudget(_ budgetId: Int) async -> Bool {
    var request = URLRequest(url: URL(string: "\(Globals.backendUrl)/budget/delete-budget/\(budgetId)")!)
    request.httpMethod = "DELETE"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")
    
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

func deleteBudgetCategory(_ budgetCategoryId: Int) async -> Bool {
    var request = URLRequest(url: URL(string: "\(Globals.backendUrl)/budget/delete-budget-categort/\(budgetCategoryId)")!)
    request.httpMethod = "DELETE"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")
    
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


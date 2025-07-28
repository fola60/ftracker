//
//  POST.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation


func postTransaction(transaction: TransactionRequest) async -> Transaction? {
    print("Attempting post: ")
    dump(transaction)

    let url = URL(string: "\(Globals.backendUrl)/transaction/post")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")

    let data = try! JSONEncoder().encode(transaction)
    request.httpBody = data
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        if statusCode == 200 {
            print("SUCCESS")
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(formatter)
            let decodedTransaction = try decoder.decode(Transaction.self, from: responseData)
            return decodedTransaction
        } else {
            print("FAILURE Status code: \(statusCode)")
            return nil
        }
    } catch {
        print("Network error: \(error)")
        return nil
    }
}

func postBudget(budget: BudgetRequest) async -> Budget? {
    print("Attempting post: ")
    dump(budget)

    let url = URL(string: "\(Globals.backendUrl)/budget/save-budget")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")

    let data = try! JSONEncoder().encode(budget)
    request.httpBody = data
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        if statusCode == 200 {
            print("SUCCESS")
            let decodedBudget = try JSONDecoder().decode(Budget.self, from: responseData)
            return decodedBudget
        } else {
            print("FAILURE Status code: \(statusCode)")
            return nil
        }
    } catch {
        print("Network error: \(error)")
        return nil
    }
}

func postBudgetCategory(budgetCategory: BudgetCategoryRequest) async -> BudgetCategory? {
    print("Attempting post: ")
    dump(budgetCategory)

    let url = URL(string: "\(Globals.backendUrl)/budget/save-budget-category")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")

    let data = try! JSONEncoder().encode(budgetCategory)
    request.httpBody = data
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        if statusCode == 200 {
            print("SUCCESS")
            let decodedBudgetCategory = try JSONDecoder().decode(BudgetCategory.self, from: responseData)
            return decodedBudgetCategory
        } else {
            print("FAILURE Status code: \(statusCode)")
            return nil
        }
    } catch {
        print("Network error: \(error)")
        return nil
    }
}

func postCategory(category: CategoryRequest) async -> Category? {
    print("Attempting post: ")
    dump(category)

    let url = URL(string: "\(Globals.backendUrl)/category/post")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")

    let data = try! JSONEncoder().encode(category)
    request.httpBody = data
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        if statusCode == 200 {
            print("SUCCESS")
            let category = try JSONDecoder().decode(Category.self, from: responseData)
            return category
        } else {
            print("FAILURE Status code: \(statusCode)")
            return nil
        }
    } catch {
        print("Network error: \(error)")
        return nil
    }
}


func attemptLogIn(user: User) async -> String{
    print("Attempting post: ")
    dump(user)
    let url = URL(string: "\(Globals.backendUrl)/user/login")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let data = try! JSONEncoder().encode(user)
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
            if let token = String(data: responseData, encoding: .utf8) {
                print("Encrypted Token: \(token)")
                return token
            } else {
                print("Failed to decode token string")
                return "FAIL"
            }
        } else {
            print("FAILURE Status code: \(statusCode)")
            return "FAIL"
        }
    } catch {
        print("Network error: \(error)")
        return "FAIL"
    }
    
    
}

func attemptSignUp(email: String, password: String) async -> String? {
    let user = User(email: email, password: password)

    guard let url = URL(string: "\(Globals.backendUrl)/user/register") else {
        print("Invalid URL")
        return nil
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let data = try JSONEncoder().encode(user)
        request.httpBody = data

        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        if let message = String(data: responseData, encoding: .utf8) {
            print("Server response (\(statusCode)): \(message)")

            // You can switch on statusCode if you want to handle specific cases:
            switch statusCode {
            case 201:
                // New user registered
                return message
            case 200:
                // Existing unverified user - verification email resent
                return message
            case 409:
                // User already exists and verified
                return message
            default:
                return "Unexpected error: \(message)"
            }
        } else {
            print("Unable to decode response as string")
            return nil
        }
    } catch {
        print("Network error: \(error)")
        return nil
    }
}

func resetPassword(email: String) async -> String? {
    guard let url = URL(string: "\(Globals.backendUrl)/user/forgot-password?email=\(email)") else {
        print("Invalid URL")
        return nil
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {

        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        if let message = String(data: responseData, encoding: .utf8) {
            print("Server response (\(statusCode)): \(message)")

            
            switch statusCode {
            case 201:
                return message
            case 200:
                return message
            case 409:
                return message
            default:
                return "Unexpected error: \(message)"
            }
        } else {
            print("Unable to decode response as string")
            return nil
        }
    } catch {
        print("Network error: \(error)")
        return nil
    }

}


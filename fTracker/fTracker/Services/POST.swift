//
//  POST.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

func postExpense(expense: Expense) async -> Bool {
    print("Attempting post:")
    dump(expense)
    let url = URL(string: "http://localhost:8080/expense/post-expense")!
    
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
    print("Attempting post:")
    dump(income)
    let url = URL(string: "http://localhost:8080/income/post-income")!
    
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
    print("Attempting post:")
    dump(recurringCharge)
    let url = URL(string: "http://localhost:8080/recurring-charges/post-recurring-charge")!
    
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
    print("Attempting post: ")
    dump(recurringRevenue)
    let url = URL(string: "http://localhost:8080/recurring-revenues/post-recurring-revenue")!
    
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



func attemptLogIn(user: User) async -> String{
    print("Attempting post: ")
    dump(user)
    let url = URL(string: "http://localhost:8080/user/login")!
    
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

    guard let url = URL(string: "http://localhost:8080/user/register") else {
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
    guard let url = URL(string: "http://localhost:8080/user/forgot-password?email=\(email)") else {
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


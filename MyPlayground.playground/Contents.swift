import UIKit
import Foundation

final class Expense: Decodable, Encodable, ObservableObject, Identifiable, Sendable {
    let type: String
    let amount: Double
    let name: String
    let description: String
    let id: Int?
    let time: Date?
    
    init(type: String, amount: Double, name: String, description: String, id: Int? = nil, time: String? = nil) {
        self.type = type
        self.amount = amount
        self.name = name
        self.description = description
        self.id = id
        if let time = time {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.time = formatter.date(from: time)
        } else {
            self.time = nil
        }
    }
    
    
    
}

final class Income: Decodable, Encodable, ObservableObject, Identifiable, Sendable {
    let type: String
    let amount: Double
    let name: String
    let description: String
    let id: Int?
    let time: Date?
    
    init(type: String, amount: Double, name: String, description: String, id: Int? = nil, time: String? = nil) {
        self.type = type
        self.amount = amount
        self.name = name
        self.description = description
        self.id = id
        if let time = time {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.time = formatter.date(from: time)
        } else {
            self.time = nil
        }
    }
}

final class RecurringCharge: Decodable, Encodable, ObservableObject, Identifiable, Sendable {
    let type: String
    let recurring_type: String
    let time_recurring: Int
    let amount: Double
    let name: String
    let description: String
    let id: Int?
    
    
    init(type: String, recurring_type: String, time_recurring: Int, amount: Double, name: String, description: String, id: Int? = nil) {
        self.type = type
        self.recurring_type = recurring_type
        self.time_recurring = time_recurring
        self.amount = amount
        self.name = name
        self.description = description
        self.id = id
    }
}

final class RecurringRevenue: Decodable, Encodable, ObservableObject, Identifiable, Sendable {
    let type: String
    let time_recurring: Int
    let amount: Double
    let name: String
    let description: String
    
    
    init(type: String, time_recurring: Int, amount: Double, name: String, description: String) {
        self.type = type
        self.time_recurring = time_recurring
        self.amount = amount
        self.name = name
        self.description = description
        
    }
}

final class User: Codable, Sendable {
    private let id: Int?
    private let email: String
    private let password: String?
    private let expenses: [Expense]?
    private let incomes: [Income]?
    private let recurringCharges: [RecurringCharge]?
    private let recurringRevenues: [RecurringRevenue]?
    
    
    init(userId: Int? = nil, email: String, password: String? = nil, expenses: [Expense]? = nil, incomes: [Income]? = nil, recurringCharges: [RecurringCharge]? = nil, recurringRevenue: [RecurringRevenue]? = nil) {
        self.id = userId
        self.email = email
        self.password = password
        self.expenses = expenses
        self.incomes = incomes
        self.recurringCharges = recurringCharges
        self.recurringRevenues = recurringRevenue
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
                return "Fail"
            }
        } else {
            print("FAILURE Status code: \(statusCode)")
            return "Fail"
        }
    } catch {
        print("Network error: \(error)")
        return "Fail"
    }
    
    
}

func attemptSignUp(email: String, password: String) async -> User? {
    let user = User(email: email, password: password)
    print("Attempting post: ")
    dump(user)
    let url = URL(string: "http://localhost:8080/user/register")!
    
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
            let decoder = JSONDecoder()
                if let user = try? decoder.decode(User.self, from: responseData) {
                    print("SUCCESS: ")
                    dump(user)
                    return user
                } else {
                    print("Failed to decode user")
                    return nil
                }
        } else {
            print("FAILURE Status code: \(statusCode)")
            return nil
        }
    } catch {
        print("Network error: \(error)")
        return nil
    }
    
    
}

//await attemptSignUp(email: "afolabiadekanle@gmail.com", password: "fola23")
func extractUserId(from jwt: String) -> Int? {
    let segments = jwt.split(separator: ".")
    guard segments.count == 3 else { return nil }

    let payloadSegment = segments[1]
    
    // Pad base64 string if needed
    var base64 = String(payloadSegment)
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    
    while base64.count % 4 != 0 {
        base64 += "="
    }

    guard let data = Data(base64Encoded: base64),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let sub = json["sub"] as? String,
          let userId = Int(sub)
    else {
        return nil
    }

    return userId
}

extractUserId(from: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzIiwiaWF0IjoxNzUyNjc2MDA3LCJleHAiOjE3ODQyMTIwMDd9.QOXeXcudH0WFEd_BIFSEo_JuFqVrOWMk7Xxm-d9wpcM")

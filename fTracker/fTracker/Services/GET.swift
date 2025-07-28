//
//  GET.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

func getTransactions() async -> [Transaction] {
    do {
        let url = URL(string: "\(Globals.backendUrl)/transaction/get-all/\(Globals.userId)")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let decoded = try decoder.decode([Transaction].self, from: data)
        return decoded
    } catch {
        print("Network error: \(error)")
        return []
    }
}

func getTransaction(_ transaction_id: Int) async -> Transaction? {
    let transactions = await getTransactions()
    return transactions.first { $0.id == transaction_id }
}

func getExpenses(userId: Int) async -> [Transaction] {
    return await getTransactions().filter{ $0.transactionType == .expense}
    
}

func getIncomes(userId: Int) async -> [Transaction] {
    return await getTransactions().filter{ $0.transactionType == .income}
}

func getRecurringExpenses(userId: Int) async -> [Transaction] {
    return await getTransactions().filter{ $0.transactionType == .recurring_expense}
}

func getRecurringIncomes(userId: Int) async -> [Transaction] {
    return await getTransactions().filter{ $0.transactionType == .recurring_income}
}

func getCategories() async -> [Category] {
    do {
        let url = URL(string: "\(Globals.backendUrl)/category/get-by-user-id/\(Globals.userId)")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        let decoded = try decoder.decode([Category].self, from: data)
        return decoded
    } catch {
        print("Network error: \(error)")
        return []
    }
}

func getBudgets() async -> [Budget] {
    do {
        let url = URL(string: "\(Globals.backendUrl)/budget/get-budget-by-user-id/\(Globals.userId)")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("Bearer \(Globals.jsonToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        let decoded = try decoder.decode([Budget].self, from: data)
        return decoded
    } catch {
        print("Network error: \(error)")
        return []
    }
}


func getSpeechFinanceRequest(speech_text: String, chats: [AIChat.ChatMessage]) async throws -> Array<SpeechResponse> {
    let url = URL(string: "http://localhost:8000/finance-request")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let recentChats = chats.suffix(5)
    let messagesText = recentChats.compactMap { chat -> String? in
        switch chat.content {
        case .text(let string):
            switch chat.sender {
            case .user:
                return "User: \(string)"
            case .ai:
                return "AI: \(string)"
            }
        default: return nil
        }
    }

    let body: [String: Any] = [
        "request": speech_text,
        "token": Globals.jsonToken,
        "chat_history": messagesText
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }

    let decoded = try JSONDecoder().decode(Array<SpeechResponse>.self, from: data)
    return decoded
}

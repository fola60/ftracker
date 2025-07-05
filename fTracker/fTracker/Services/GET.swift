//
//  GET.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//
import Foundation

func getExpenses(userId: Int) async throws -> Array<Expense> {
    
    let url = URL(string: "http://localhost:8080/expense/get-expense-by-user-id/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    decoder.dateDecodingStrategy = .formatted(formatter)
    let decoded = try decoder.decode([Expense].self, from: data)
    
    return decoded
}

func getIncomes(userId: Int) async throws -> Array<Income> {
    let url = URL(string: "http://localhost:8080/income/get-income-by-user-id/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    decoder.dateDecodingStrategy = .formatted(formatter)
    let decoded = try decoder.decode([Income].self, from: data)
    
    return decoded;
}

func getRecurringCharges(userId: Int) async throws -> Array<RecurringCharge> {
    let url = URL(string: "http://localhost:8080/recurring-charges/get-recurring-charge/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let decoded = try decoder.decode([RecurringCharge].self, from: data)
    
    return decoded;
}

func getRecurringRevenues(userId: Int) async throws -> Array<RecurringRevenue> {
    let url = URL(string: "http://localhost:8080/recurring-revenues/get-recurring-revenue/\(userId)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let decoded = try decoder.decode([RecurringRevenue].self, from: data)
    
    return decoded;
}

func getSpeechFinanceRequest(speech_text: String) async throws -> Array<SpeechResponse> {
    let url = URL(string: "http://localhost:8000/finance-request?request=\(speech_text)")!
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    let decoded = try JSONDecoder().decode(Array<SpeechResponse>.self, from: data)
    return decoded
}

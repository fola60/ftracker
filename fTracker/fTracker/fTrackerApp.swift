//
//  fTrackerApp.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//

import SwiftUI

@main
struct fTrackerApp: App {
    @State private var currentScreen: Screen = .loading
    @State private var chats: [AIChat.ChatMessage] = []

    enum Screen {
        case landing
        case list
        case analytics
        case tools
        case budget
        case auth
        case loading
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch currentScreen {
                case .auth:
                    AuthView(navigateTo: $currentScreen)
                case .landing:
                    LandingPage(navigateTo: $currentScreen)
                case .list:
                    ListView(navigateTo: $currentScreen)
                case .analytics:
                    AnalyticView(navigateTo: $currentScreen, chats: $chats)
                case .tools:
                    ToolView(navigateTo: $currentScreen)
                case .budget:
                    BudgetView(navigateTo: $currentScreen)
                case .loading:
                    VStack {
                        ProgressView("Checking session...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                        Text("Please wait while we sign you in...")
                            .foregroundColor(.gray)
                    }
                    
                }
            }
            .task {
                if await Globals.isUserSignedIn() {
                    let recurringExpenses: [Transaction] = await getRecurringExpenses(userId: Globals.userId)
                    let recurringIncomes: [Transaction] = await getRecurringIncomes(userId: Globals.userId)
                    let now = Date()
                    
                    let _ = await computeRecurringTransactions(for: recurringIncomes)
                    let _ = await computeRecurringTransactions(for: recurringExpenses)
                    
                    for recurringIncome in recurringIncomes {
                        
                    }
                    currentScreen = .landing
                } else {
                    currentScreen = .auth
                }
            }
        }
    }
    
    
    private func computeRecurringTransactions(for transactions: [Transaction]) async {
        let now = Date()
        for transaction in transactions {
            
            guard var time = transaction.time, let time_recurring = transaction.time_recurring, time_recurring > 0 else {
                continue
            }
            
            if let newTime = Calendar.current.date(byAdding: .day, value: time_recurring, to: time) {
                time = newTime
            } else {
                break
            }
            
            if (time <= now) {
                let _ = await deleteTransaction(transaction.id ?? -1)
            } else {
                continue
            }
            
            print(time)
            
            while (time <= now) {
                
                var type: TransactionType {
                    switch transaction.transactionType {
                    case .income:
                        return .income
                    case .expense:
                        return .expense
                    case .recurring_expense:
                        return .expense
                    case .recurring_income:
                        return .income
                    }
                }
                
                let newTransaction = TransactionRequest(category_id: transaction.category.id ?? -1, time: time, amount: transaction.amount, name: transaction.name, description: transaction.description, transaction_type: type, time_recurring: nil, user_id: 4)
                let _ = await postTransaction(transaction: newTransaction)
                
                if let newTime = Calendar.current.date(byAdding: .day, value: time_recurring, to: time) {
                    time = newTime
                } else {
                    break
                }
            }
            
            let newTransaction = TransactionRequest(category_id: transaction.category.id ?? -1, time: time, amount: transaction.amount, name: transaction.name, description: transaction.description, transaction_type: transaction.transactionType, time_recurring: transaction.time_recurring, user_id: 4)
            let _ = await postTransaction(transaction: newTransaction)
        }
    }

}

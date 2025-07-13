//
//  ListView.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 02/07/2025.
//

import SwiftUI

struct ListView: View {
    @State var incomes: Array<Income> = []
    @State var expenses: Array<Expense> = []
    
    
    @State var incomesByDate: [Date: [Income]] = [:]
    @State var expensesByDate: [Date: [Expense]] = [:]
    
    @State var sortedDates: [Date] = []
    
    @State var totalIncome: Double = 0.0
    @State var totalExpense: Double = 0.0
    
    @State private var hasLoaded: Bool = false

    private func loadData() async {
        do {
            let fetchedIncomes = try await getIncomes(userId: Globals.userId)
            let fetchedExpenses = try await getExpenses(userId: Globals.userId)
            print("fetching")
            print(fetchedIncomes)
            print(fetchedExpenses)
            
            await MainActor.run {
                
                self.incomes = fetchedIncomes
                self.expenses = fetchedExpenses
                
                
                incomesByDate = Dictionary(grouping: incomes) { income in
                    totalIncome += income.amount
                    return income.time!
                }
                
                
                expensesByDate = Dictionary(grouping: expenses) { expense in
                    totalExpense += expense.amount
                    return expense.time!
                }
                
                
                
                for date in incomesByDate.keys {
                    sortedDates.append(date)
                }
                
                for date in expensesByDate.keys {
                    sortedDates.append(date)
                }
                
                var allDates = Set<Date>()
                allDates.formUnion(incomesByDate.keys)
                allDates.formUnion(expensesByDate.keys)
                sortedDates = Array(allDates).sorted(by: >)
            }
        } catch {
            
        }
    }
    
    var body: some View {
            NavigationView {
                listContent
                    .navigationTitle("Financial Overview")
                    .task {
                        await loadData()
                    }
            }
            
        }
        
    private var listContent: some View {
        List {
            ForEach(sortedDates, id: \.self) { date in
                dateSection(for: date)
            }
            
        }
        
    }
    
    private func dateSection(for date: Date) -> some View {
        Section {
            expenseRows(for: date)
            incomeRows(for: date)
        } header: {
            sectionHeader(for: date)
        }
    }
    
    @ViewBuilder
    private func expenseRows(for date: Date) -> some View {
        if let dayExpenses = expensesByDate[date] {
            ForEach(dayExpenses, id: \.id) { expense in
                expenseRow(expense)
            }
        }
    }
    
    @ViewBuilder
    private func incomeRows(for date: Date) -> some View {
        if let dayIncomes = incomesByDate[date] {
            ForEach(dayIncomes, id: \.id) { income in
                incomeRow(income)
            }
        }
    }
    
    private func expenseRow(_ expense: Expense) -> some View {
        HStack {
            itemDetails(title: expense.name, description: expense.description)
            Spacer()
            Text("-\(Globals.currencySymbol)\(expense.amount, specifier: "%.2f")")
                .foregroundColor(.red)
                .font(.headline)
        }
    }
    
    private func incomeRow(_ income: Income) -> some View {
        HStack {
            itemDetails(title: income.name, description: income.description)
            Spacer()
            Text("+\(Globals.currencySymbol)\(income.amount, specifier: "%.2f")")
                .foregroundColor(.green)
                .font(.headline)
        }
    }
    
    private func itemDetails(title: String, description: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            if let description = description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func sectionHeader(for date: Date) -> some View {
        HStack {
            Text(formatDate(date))
                .font(.headline)
                .font(.system(size: 32))
                .fontWeight(.heavy)
                .foregroundStyle(.black)
            Spacer()
            totalText(for: date)
        }
    }
    
    private func totalText(for date: Date) -> some View {
        let total = calculateDayTotal(for: date)
        return Text("\(Globals.currencySymbol)\(total, specifier: "%.2f")")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(total >= 0 ? .green : .red)
    }
    
    
    private func calculateDayTotal(for date: Date) -> Double {
            let dayIncomes = incomesByDate[date]?.reduce(0) { $0 + $1.amount } ?? 0
            let dayExpenses = expensesByDate[date]?.reduce(0) { $0 + $1.amount } ?? 0
            return dayIncomes - dayExpenses
        }
        
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
}

private let sampleIncomes: [Income] = [
    Income(type: "Salary", amount: 2500.00, name: "Monthly Salary", description: "July salary", id: 1, time: "2025-07-01"),
    Income(type: "Freelance", amount: 800.00, name: "Freelance Project", description: "Web design project", id: 2, time: "2025-07-02"),
    Income(type: "Gift", amount: 150.00, name: "Birthday Gift", description: "Gift from friend", id: 3, time: "2025-06-30")
]

private let sampleeExpenses: [Expense] = [
    Expense(type: "Groceries", amount: 120.75, name: "Grocery Shopping", description: "Weekly groceries", id: 1, time: "2025-07-01"),
    Expense(type: "Transport", amount: 45.00, name: "Bus Pass", description: "Monthly bus ticket", id: 2, time: "2025-07-01"),
    Expense(type: "Dining", amount: 60.00, name: "Dinner Out", description: "Dinner with friends", id: 3, time: "2025-07-02"),
    Expense(type: "Subscription", amount: 12.99, name: "Spotify", description: "Music subscription", id: 4, time: "2025-06-30"),
    
]

#Preview {
    ListView(incomes: sampleIncomes, expenses: sampleeExpenses)
}

//
//  ChartView.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 02/07/2025.
//

import SwiftUI
import Charts

struct ChartView: View {
    enum ChartType {
        case inc, exp
    }
    
    @State var expenses: Array<Expense> = []
    @State var incomes: Array<Income> = []
    @State private var totalExpenseByDay: [Double] = []
    
    let type: ChartType
    
    
    private func loadData() async {
        do {
            let fetchedIncomes = try await getIncomes(userId: Globals.userId)
            let fetchedExpenses = try await getExpenses(userId: Globals.userId)
            
            incomes = fetchedIncomes.sorted {
                guard let time0 = $0.time, let time1 = $1.time else {
                    return $0.time != nil
                }
                return time0 < time1
            }
            
            expenses = sampleExpenses
            
            
            var total: Double = 0
            for expense in expenses {
                total += expense.amount
                totalExpenseByDay.append(total)
                print(total)
            }
            print(totalExpenseByDay)
            print(expenses)
            
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        
        Text("SPENT THIS MONTH")
            .foregroundStyle(.gray)
            .fontWeight(.medium)
        if (expenses.count == totalExpenseByDay.count && expenses.count > 0) {
            Text("\(Globals.currencySymbol)\(totalExpenseByDay[expenses.count - 1], specifier: "%.2f")")
                .font(.system(size: 32))
                .fontWeight(.heavy)
        } else {
            Text("\(Globals.currencySymbol)0")
        }
        Chart {
            if expenses.count == totalExpenseByDay.count {
                ForEach(Array(expenses.enumerated()), id: \.element.id) { index, expense in
                    if let time = expense.time {
                        let date = Calendar.current.dateComponents([.day], from: time)
                        LineMark(
                            x: .value("Day", date.day ?? 1),
                            y: .value("Amount", totalExpenseByDay[index])
                        )
                        .lineStyle(StrokeStyle(lineWidth: 5))
                        
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: [1, 6, 11, 16, 21, 26, 31]) { _ in
                AxisGridLine().foregroundStyle(.clear)
                AxisTick().foregroundStyle(.clear)
                AxisValueLabel()
            }
        }
        .frame(width: 360, height: 150)
        .task {
            await loadData()
            print("Expense indices and values:")
            for (index, expense) in expenses.enumerated() {
                print(index, expense)
            }
        }
        .padding()
    }
    
    
}

private let sampleIncomes: [Income] = [
    Income(type: "Salary", amount: 2500.00, name: "Monthly Salary", description: "July salary", id: 1, time: "2025-07-01"),
    Income(type: "Freelance", amount: 800.00, name: "Freelance Project", description: "Web design project", id: 2, time: "2025-07-02"),
    Income(type: "Gift", amount: 150.00, name: "Birthday Gift", description: "Gift from friend", id: 3, time: "2025-06-30")
]

let sampleExpenses: [Expense] = [
    Expense(type: "Groceries", amount: 120.75, name: "Grocery Shopping", description: "Weekly groceries", id: 1, time: "2025-07-01"),
    Expense(type: "Transport", amount: 45.00, name: "Bus Pass", description: "Monthly bus ticket", id: 2, time: "2025-07-01"),
    Expense(type: "Dining", amount: 60.00, name: "Dinner Out", description: "Dinner with friends", id: 3, time: "2025-07-02"),
    Expense(type: "Utilities", amount: 85.40, name: "Electricity Bill", description: "Monthly electricity", id: 4, time: "2025-07-03"),
    Expense(type: "Entertainment", amount: 25.50, name: "Movie Tickets", description: "Cinema night", id: 5, time: "2025-07-05"),
    Expense(type: "Groceries", amount: 67.20, name: "Fresh Produce", description: "Fruits and vegetables", id: 6, time: "2025-07-07"),
    Expense(type: "Healthcare", amount: 150.00, name: "Doctor Visit", description: "Routine checkup", id: 7, time: "2025-07-09"),
    Expense(type: "Shopping", amount: 89.99, name: "Clothing", description: "Summer shirt", id: 8, time: "2025-07-11"),
    Expense(type: "Dining", amount: 32.75, name: "Coffee & Lunch", description: "Work lunch", id: 9, time: "2025-07-12"),
    Expense(type: "Transport", amount: 18.60, name: "Gas Station", description: "Fuel for car", id: 10, time: "2025-07-15"),
    Expense(type: "Subscriptions", amount: 12.99, name: "Netflix", description: "Monthly streaming", id: 11, time: "2025-07-16"),
    Expense(type: "Groceries", amount: 94.35, name: "Bulk Shopping", description: "Costco run", id: 12, time: "2025-07-18"),
    Expense(type: "Entertainment", amount: 75.00, name: "Concert Tickets", description: "Live music event", id: 13, time: "2025-07-22")
    
]

#Preview {
    ChartView(type: .exp)
}

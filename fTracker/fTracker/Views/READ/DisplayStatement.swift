//
//  DisplayStatement.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 28/06/2025.
//

import SwiftUI

struct DisplayStatement: View {
    let removeStatement: (Int, ItemType) -> Void
    let expense: Expense?
    let income: Income?
    let recurringCharge: RecurringCharge?
    let recurringRevenue: RecurringRevenue?
    let id: Int
    let type: ItemType
    @State private var isExpanded: Bool = false
    
    var name: String {
        switch type {
        case .income:
            return income?.name ?? ""
        case .expense:
            return expense?.name ?? ""
        case .recurring_charge:
            return recurringCharge?.name ?? ""
        case .recurring_revenue:
            return recurringRevenue?.name ?? ""
        case .error:
            return "Error"
        }
    }
    
    var price: Double {
        switch type {
        case .income:
            return income?.amount ?? 0.00
        case .expense:
            return expense?.amount ?? 0.00
        case .recurring_charge:
            return recurringCharge?.amount ?? 0.00
        case .recurring_revenue:
            return recurringRevenue?.amount ?? 0.00
        case .error:
            return 0.00
        }
    }
    
    var description: String {
        switch type {
        case .income:
            return income?.description ?? ""
        case .expense:
            return expense?.description ?? ""
        case .recurring_charge:
            return recurringCharge?.description ?? ""
        case .recurring_revenue:
            return recurringRevenue?.description ?? ""
        case .error:
            return "Error"
        }
    }
    
    var frequency: Int? {
        switch type {
        case .income:
            return -1
        case .expense:
            return -1
        case .recurring_charge:
            return recurringCharge?.time_recurring ?? -1
        case .recurring_revenue:
            return recurringRevenue?.time_recurring ?? -1
        case .error:
            return -1
        }
    }
    
    var color: Color {
        switch type {
        case .income:
            return .green
        case .expense:
            return .red
        case .recurring_charge:
            return .orange
        case .recurring_revenue:
            return .blue
        case .error:
            return .gray
        }
    }
    
    var sign: String {
        switch type {
        case .income:
            return "+"
        case .expense:
            return "-"
        case .recurring_charge:
            return "-"
        case .recurring_revenue:
            return "+"
        case .error:
            return ""
        }
        
    
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.black)
                        .fontWeight(.heavy)
                    Spacer()
                    Text("\(sign)\(Globals.currencySymbol)\(String(format: "%.2f", price))")
                        .foregroundStyle(color)
                }
                Spacer()
                    .frame(maxHeight:20)
                HStack {
                    Text("\(type)").textCase(.uppercase)
                        .font(.headline)
                        .foregroundStyle(color)
                    Spacer()
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up": "chevron.down")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                    }
                    Spacer()
                    Button {
                        removeStatement(id, type)
                    } label: {
                        Image(systemName: "delete.left")
                            .foregroundStyle(.gray)
                            .imageScale(.large)
                    }
                }
                VStack {
                    if isExpanded {
                        Text(description)
                            .foregroundStyle(.gray.opacity(0.9))
                            .padding()
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    
}

#Preview {
    VStack {
        DisplayStatement(
            removeStatement: {_,_ in },
            expense: Expense(type: "EXPENSE", amount: 2.5, name: "Coffee", description: "Morning coffee at cafe"),
            income: nil,
            recurringCharge: nil,
            recurringRevenue: nil,
            id: 0,
            type: ItemType.expense
        )
        DisplayStatement(
            removeStatement: {_,_ in },
            expense: nil,
            income: Income(type: "INCOME", amount: 332.5, name: "susi", description: "Morning coffee at cafe"),
            recurringCharge: nil,
            recurringRevenue: nil,
            id: 0,
            type: ItemType.income
        )
        DisplayStatement(
            removeStatement: {_,_ in },
            expense: nil,
            income: nil,
            recurringCharge: RecurringCharge(type: "OTHER", recurring_type: "OTHER", time_recurring: 30, amount: 50.00, name: "SOME RECURRING CHARGE", description: "HEY THIS IS A RECURRING CHARGE"),
            recurringRevenue: nil,
            id: 0,
            type: ItemType.recurring_charge
        )
        DisplayStatement(
            removeStatement: {_,_ in },
            expense: nil,
            income: nil,
            recurringCharge: nil,
            recurringRevenue: RecurringRevenue(type: "OTHER", time_recurring: 30, amount: 200.00, name: "SALARY", description: "HEY"),
            id: 0,
            type: ItemType.recurring_revenue
        )
    }
    .padding()
}

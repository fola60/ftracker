//
//  CreateRecurringRevenue.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 18/06/2025.
//

import SwiftUI

struct CreateRecurringRevenue: View {
    enum FocusedField {
        case str1, str2, dec, int
    }
    
    @State private var time_recurring: String = "30"
    @State private var type: String = "OTHER"
    @State private var amount: String = ""
    @State private var name: String = ""
    @State private var description: String = ""
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("name",text: $name)
                    .focused($focusedField, equals: .str1)
                TextField("description", text: $description)
                    .focused($focusedField, equals: .str2)
                Picker("Type", selection: $type) {
                    Text("Other").tag("OTHER")
                    Text("Financial Aid").tag("FINANCIAL_AID")
                    Text("Salary").tag("SALARY")
                    Text("Savings").tag("SAVINGS")
                }
                TextField("Amount €", text: $amount)
                    .focused($focusedField, equals: .dec)
                    .keyboardType(.decimalPad)
                HStack {
                    Text("Frequency")
                    TextField("Frequency", text: $time_recurring)
                        .focused($focusedField, equals: .int)
                        .keyboardType(.numberPad)
                }
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button {
                            focusedField = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save" ,action: saveIncome)
                            .disabled(name.isEmpty || description.isEmpty || amount.isEmpty || time_recurring.isEmpty)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Exit", action: goBack)
                            .accentColor(.red)
                    }
                }
                
            }
            .navigationTitle("Create new recurring revenue")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    func saveIncome() {
        
        guard let doubleAmount = Double(amount) else {
            return
        }
        
        guard let intTimeRecurring = Int(time_recurring) else {
            return
        }
        let createRecurringRevenue = RecurringRevenue(type: type,time_recurring: intTimeRecurring , amount: doubleAmount, name: name, description: description)
        Task {
            let _ = await postRecurringRevenue(recurringRevenue: createRecurringRevenue)
        }
        
    }
    
    func goBack() {
        
    }
}

#Preview {
    CreateRecurringRevenue()
}

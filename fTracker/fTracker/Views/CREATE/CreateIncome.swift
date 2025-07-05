//
//  CreateIncome.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 17/06/2025.
//

import SwiftUI

struct CreateIncome: View {
    let userId = 1;
    enum FocusedField {
        case str1, str2, dec
    }
    
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
                    Text("Deposits").tag("DEPOSITS")
                    Text("Salary").tag("SALARY")
                    Text("Savings").tag("SAVINGS")
                }
                TextField("Amount €", text: $amount)
                    .focused($focusedField, equals: .dec)
                    .keyboardType(.decimalPad)
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
                            .disabled(name.isEmpty || description.isEmpty || amount.isEmpty)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Exit", action: goBack)
                            .accentColor(.red)
                    }
                }
                
            }
            .navigationTitle("Create new income")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    func saveIncome() {
        
        guard let doubleAmount = Double(amount) else {
            return
        }
        let createdIncome = Income(type: type, amount: doubleAmount, name: name, description: description)
        Task {
            let _ = await postIncome(income: createdIncome)
        }
        
    }
    
    func goBack() {
        
    }
}

#Preview {
    CreateIncome()
}

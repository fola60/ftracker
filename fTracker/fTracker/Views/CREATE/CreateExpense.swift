//
//  CreateExpense.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 18/06/2025.
//

import SwiftUI

struct CreateExpense: View {
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
                    Text("Bills").tag("BILLS")
                    Text("Car").tag("CAR")
                    Text("Clothes").tag("CLOTHES")
                    Text("Communications").tag("COMMUNICATIONS")
                    Text("Eating Out").tag("EATING_OUT")
                    Text("Entertainment").tag("ENTERTAINMENT")
                    Text("Groceries").tag("GROCERIES")
                    Text("Gifts").tag("GIFTS")
                    Text("Health").tag("HEALTH")
                    Text("House").tag("HOUSE")
                    Text("Pets").tag("PETS")
                    Text("Sports").tag("SPORTS")
                    Text("Transportation").tag("TRANSPORTATION")
                    Text("Other").tag("OTHER")
                }
                TextField("Cost €", text: $amount)
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
                        Button("Save" ,action: saveExpense)
                            .disabled(name.isEmpty || description.isEmpty || amount.isEmpty)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Exit", action: goBack)
                            .accentColor(.red)
                    }
                }
                
            }
            .navigationTitle("Create new expense")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    func saveExpense() {
        
        guard let doubleAmount = Double(amount) else {
            return
        }
        let createdExpense = Expense(type: type, amount: doubleAmount, name: name, description: description)
        Task {
            let _ = await postExpense(expense: createdExpense)
        }
        
    }
    
    func goBack() {
        
    }
}

#Preview {
    CreateExpense()
}

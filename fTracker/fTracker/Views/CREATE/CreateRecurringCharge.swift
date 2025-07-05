//
//  CreateRecurringCharge.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 19/06/2025.
//

import SwiftUI

struct CreateRecurringCharge: View {
    enum FocusedField {
        case str1, str2, dec, int
    }
    
    @State private var time_recurring: String = "30"
    @State private var type: String = "OTHER"
    @State private var charge_type: String = "OTHER"
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
                Picker("Charge Type", selection: $charge_type) {
                    Text("Other").tag("OTHER")
                    Text("Subscriptions").tag("SUBSCRIPTIONS")
                    Text("Bills").tag("BILLS")
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
                        Button("Save" ,action: saveRecurringCharge)
                            .disabled(name.isEmpty || description.isEmpty || amount.isEmpty || time_recurring.isEmpty)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            Task {
                                await goBack()
                            }
                        } label: {
                            Text("Back")
                        }
                        .accentColor(.red)
                    }
                }
                
            }
            .navigationTitle("Create new recurring charge")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
    
    func saveRecurringCharge() {
        
        guard let doubleAmount = Double(amount) else {
            return
        }
        
        guard let intTimeRecurring = Int(time_recurring) else {
            return
        }
        let createRecurringCharge = RecurringCharge(type: type, recurring_type: charge_type,time_recurring: intTimeRecurring , amount: doubleAmount, name: name, description: description)
        Task {
            let _ = await postRecurringCharge(recurringCharge: createRecurringCharge)
        }
        
    }
    
    func goBack() {
        
    }
}

#Preview {
    CreateRecurringCharge()
}

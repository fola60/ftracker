import SwiftUI

struct TransactionView: View {
    enum FocusedField {
        case str1, str2
    }
    
    let transaction: Transaction?
    let create: Bool
    let onTransactionChanged: (() -> Void)? // Add callback parameter
    
    private var transactionType: TransactionType {
        if isIncome {
            if time_recurring != nil {
                return .recurring_income
            } else {
                return .income
            }
        } else {
            if time_recurring != nil {
                return .recurring_expense
            } else {
                return .expense
            }
        }
    }
    @State private var id: Int?
    @State private var isIncome: Bool
    @State private var amount: Float
    @State private var name: String
    @State private var description: String
    @State private var time: Date
    @State private var time_recurring: Int?
    @State private var category: Category
    @State private var showKeypad = false
    @State private var showScrollpad = false
    @State private var showCategory = false
    @FocusState private var focusField: FocusedField?
    @Environment(\.dismiss) var dismiss
    
    private var dayToStringMap = [nil:"Never Repeat", 1:"Every Day", 7: "Every Week", 14: "Every other week", 30: "Every month", 60: "Every other month", 90: "Every 3 months", 365: "Every year"]
    
    
    init(transaction: Transaction?, create: Bool, onTransactionChanged: (() -> Void)? = nil) {
        self.transaction = transaction
        self.create = create
        self.onTransactionChanged = onTransactionChanged
        id = transaction?.id
        isIncome = transaction?.transactionType == .income || transaction?.transactionType == .recurring_income
        amount = transaction?.amount ?? 0.00
        name = transaction?.name ?? ""
        description = transaction?.description ?? ""
        time = transaction?.time ?? Date()
        time_recurring = transaction?.time_recurring
        category = transaction?.category ?? Globals.defaultCategory
    }
    
    public func colorForHeadCategory(_ headCategory: HeadCategoryType) -> Color {
        switch headCategory {
        case .entertainment:
            return .purple
        case .food_and_drinks:
            return .orange
        case .housing:
            return .blue
        case .income:
            return .green
        case .lifestyle:
            return .pink
        case .miscellaneous:
            return .gray
        case .savings:
            return .mint
        case .transportation:
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    Text(create ? "Create Transaction" : "Edit Transaction")
                }
                .font(.system(size: 26))
                .fontWeight(.light)
                .foregroundStyle(.gray)
                .padding()
                
                Text("\(Globals.currencySymbol)\(String(format: "%.2f", amount))")
                    .font(.system(size: 32))
                    .foregroundStyle(.black)
                    .fontWeight(.heavy)
                    .padding()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showKeypad = true
                        }
                    }
                
                HStack(spacing: 20) {
                    Button {
                        isIncome = false
                    } label: {
                        Text("Expense")
                    }
                    .frame(width: 150, height: 40)
                    .foregroundStyle(.black)
                    .background(!isIncome ? .gray.opacity(0.1) : .white)
                    .cornerRadius(15)
                    
                    Button {
                        isIncome = true
                    } label: {
                        Text("Income")
                    }
                    .frame(width: 150, height: 40)
                    .foregroundStyle(.black)
                    .background(isIncome ? .gray.opacity(0.1) : .white)
                    .cornerRadius(15)
                }
                
                HStack {
                    Image(systemName: "note.text")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading)
                    TextField("Name",text: $name)
                        .focused($focusField, equals: .str1)
                    Spacer()
                }
                .padding()
                
                HStack {
                    Image(systemName: CategoryView.iconForCategory(category.name))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading)
                        .foregroundStyle(colorForHeadCategory(category.headCategory))
                    Text("Category: ")
                    Text(category.name)
                        .foregroundStyle(colorForHeadCategory(category.headCategory))
                    Spacer()
                }
                .padding()
                .onTapGesture {
                    showCategory = true
                }
                .sheet(isPresented: $showCategory) {
                    CategoryView(category: $category)
                }
                
                HStack {
                    Image(systemName: "note.text")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading)
                    TextField("Description",text: $description)
                        .focused($focusField, equals: .str2)
                    Spacer()
                }
                .padding()
                
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading)
                    CalendarView(selectedDate: $time)
                    Spacer()
                }
                .padding()
                
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 30, height: 35)
                        .padding(.leading)
                    
                    Text("\(dayToStringMap[time_recurring] ?? "Every \(time_recurring ?? 0) days")")
                        .onTapGesture {
                            showScrollpad = true
                        }
                        .sheet(isPresented: $showScrollpad) {
                            ScrollpadView(time_recurring: $time_recurring)
                                .presentationDetents([.fraction(0.43)])
                                .presentationDragIndicator(.hidden)
                        }
                    Spacer()
                }
                .padding()
                
                HStack {
                    if !create {
                        Button {
                            Task {
                                await deleteTransactionLocal()
                            }
                        } label: {
                            Image(systemName: "trash.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.black)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                )
                        }
                    }
                    Button {
                        Task {
                            await saveTransactionLocal()
                        }
                    } label: {
                        Text("Save")
                            .foregroundStyle(.white)
                            .font(.system(size: 24))
                            .frame(width: create ? 380 : 280, height: 45)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            .blur(radius: showKeypad ? 5 : 0)
            .disabled(showKeypad)
            
            
            if showKeypad {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showKeypad = false
                        }
                    }
                
                VStack {
                    Spacer()
                    KeypadView(amount: $amount, isPresented: $showKeypad)
                        .frame(height: UIScreen.main.bounds.height * 0.43)
                        .background(.regularMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    focusField = nil
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
    }
    
    private func saveTransactionLocal() async {
        if !create {
            let _ = await deleteTransaction(transaction?.id ?? 1)
        }
        let transactionRequest = TransactionRequest(category_id: category.id ?? -1, time: time, amount: amount, name: name, description: description, transaction_type: transactionType, time_recurring: time_recurring, user_id: Globals.userId)
        let _ = await postTransaction(transaction: transactionRequest)
        
        
        onTransactionChanged?()
        
        dismiss()
    }
    
    private func deleteTransactionLocal() async {
        let _ = await deleteTransaction(transaction?.id ?? -1)
        
        
        onTransactionChanged?()
        
        dismiss()
    }
}

#Preview {
    TransactionView(transaction: nil, create: false)
}

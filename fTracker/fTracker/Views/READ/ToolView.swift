import SwiftUI

struct ToolView: View {
    @Binding var navigateTo: fTrackerApp.Screen
    @State private var showRecurringTransactions = false
    
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding()
                    
                    Text("Tools")
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .font(.system(size: 32))
                    
                    Spacer()
                        .frame(width: 50)
                }
                .padding()
                
                VStack(spacing: 16) {
                    // Recurring Transactions Button
                    Button(action: {
                        showRecurringTransactions = true
                    }) {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Manage Recurring Transactions")
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: {
                    Globals.logOut()
                    navigateTo = .auth
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                FooterView(navigateTo: $navigateTo, section: .tool)
            }
        }
        .sheet(isPresented: $showRecurringTransactions) {
            RecurringTransactionView()
                .presentationDetents([.fraction(0.97)])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct RecurringTransactionView: View {
    @State private var recurringTransactions: [Transaction] = []
    @State private var hasLoaded: Bool = false
    @State private var selectedTransaction: Transaction? = nil
    @State private var showCreateTransaction = false
    @Environment(\.dismiss) var dismiss
    
    private var recurringIncomes: [Transaction] {
        recurringTransactions.filter { $0.transactionType == .recurring_income }
    }
    
    private var recurringExpenses: [Transaction] {
        recurringTransactions.filter { $0.transactionType == .recurring_expense }
    }
    
    private var dayToStringMap = [nil:"Never Repeat", 1:"Every Day", 7: "Every Week", 14: "Every other week", 30: "Every month", 60: "Every other month", 90: "Every 3 months", 365: "Every year"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Recurring Transactions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        showCreateTransaction = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                if recurringTransactions.isEmpty && hasLoaded {
                    
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "repeat")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Recurring Transactions")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Text("Create recurring income or expenses to see them here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    List {
                        
                        if !recurringIncomes.isEmpty {
                            Section {
                                ForEach(recurringIncomes, id: \.id) { transaction in
                                    recurringTransactionRow(transaction, isIncome: true)
                                        .listRowBackground(Color.white)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        .onTapGesture {
                                            selectedTransaction = transaction
                                        }
                                }
                            } header: {
                                sectionHeader(title: "Recurring Income", color: .green)
                            }
                        }
                        
                        // Recurring Expenses Section
                        if !recurringExpenses.isEmpty {
                            Section {
                                ForEach(recurringExpenses, id: \.id) { transaction in
                                    recurringTransactionRow(transaction, isIncome: false)
                                        .listRowBackground(Color.white)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        .onTapGesture {
                                            selectedTransaction = transaction
                                        }
                                }
                            } header: {
                                sectionHeader(title: "Recurring Expenses", color: .red)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(.white))
                    .scrollContentBackground(.hidden)
                }
            }
            .task {
                if !hasLoaded {
                    await loadRecurringTransactions()
                    hasLoaded = true
                }
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionView(transaction: transaction, create: false)
                    .presentationDetents([.fraction(0.97)])
                    .presentationDragIndicator(.hidden)
                    .onDisappear {
                        Task {
                            await loadRecurringTransactions()
                        }
                    }
            }
            .sheet(isPresented: $showCreateTransaction) {
                TransactionView(transaction: nil, create: true)
                    .presentationDetents([.fraction(0.97)])
                    .presentationDragIndicator(.hidden)
                    .onDisappear {
                        Task {
                            await loadRecurringTransactions()
                        }
                    }
            }
        }
    }
    
    private func recurringTransactionRow(_ transaction: Transaction, isIncome: Bool) -> some View {
        HStack(spacing: 12) {
            VStack {
                Image(systemName: CategoryView.iconForCategory(transaction.category.name))
                    .font(.title2)
                    .foregroundColor(CategoryView.colorForHeadCategory(transaction.category.headCategory))
                    .frame(width: 30, height: 30)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.name)
                        .font(.headline)
                    
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if !transaction.description.isEmpty {
                    Text(transaction.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                
                Text(dayToStringMap[transaction.time_recurring] ?? "Every \(transaction.time_recurring ?? 0) days")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Text("\(isIncome ? "+" : "-")\(Globals.currencySymbol)\(transaction.amount, specifier: "%.2f")")
                .foregroundColor(isIncome ? .green : .red)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func sectionHeader(title: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(color)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets())
    }
    
    private func loadRecurringTransactions() async {
        let allTransactions = await getTransactions()
        
        await MainActor.run {
            self.recurringTransactions = allTransactions.filter { transaction in
                transaction.transactionType == .recurring_income || transaction.transactionType == .recurring_expense
            }
        }
    }
}

#Preview {
    @Previewable @State var navigate: fTrackerApp.Screen = .tools
    ToolView(navigateTo: $navigate)
}

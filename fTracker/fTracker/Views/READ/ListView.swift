import SwiftUI

struct ListView: View {
    
    @Binding var navigateTo: fTrackerApp.Screen
    @State private var transactions: [Transaction] = []
    @State private var transactionsByDate: [Date: [Transaction]] = [:]
    @State private var sortedDates: [Date] = []
    @State private var totalIncome: Double = 0.0
    @State private var totalExpense: Double = 0.0
    @State private var hasLoaded: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var selectedTransaction: Transaction? = nil
    @State private var refreshTrigger = UUID()
    
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            guard let transactionDate = transaction.time else { return false }
            guard calendar.isDate(transactionDate, equalTo: selectedDate, toGranularity: .month) else { return false }
            return transaction.transactionType != .recurring_income && transaction.transactionType != .recurring_expense
        }
    }
    
    init(navigateTo: Binding<fTrackerApp.Screen>, transactions: [Transaction] = [], transactionsByDate: [Date : [Transaction]] = [:], sortedDates: [Date] = [], totalIncome: Double = 0.0, totalExpense: Double = 0.0, hasLoaded: Bool = false, selectedDate: Date = Date()) {
        self._navigateTo = navigateTo
        self.transactions = transactions
        self.transactionsByDate = transactionsByDate
        self.sortedDates = sortedDates
        self.totalIncome = totalIncome
        self.totalExpense = totalExpense
        self.hasLoaded = hasLoaded
        self.selectedDate = selectedDate
        
    }
    

    private func loadData() async {
        
        let fetchedTransactions = await getTransactions()
        
        
        await MainActor.run {
            self.transactions = fetchedTransactions
            updateFilteredData()
        }
   
        
    }
    
    private func groupTransactionsByDate() {
        transactionsByDate = Dictionary(grouping: filteredTransactions) { transaction in
            guard let date = transaction.time else { return Date() }
            return Calendar.current.startOfDay(for: date)
        }
    }
    
    private func calculateTotals() {
        totalIncome = 0.0
        totalExpense = 0.0
        
        for transaction in filteredTransactions {
            switch transaction.transactionType {
            case .income, .recurring_income:
                totalIncome += Double(transaction.amount)
            case .expense, .recurring_expense:
                totalExpense += Double(transaction.amount)
            }
        }
    }
    
    private func updateFilteredData() {
        groupTransactionsByDate()
        calculateTotals()
        createSortedDates()
    }
    
    private func createSortedDates() {
        let allDates = Set(transactionsByDate.keys)
        sortedDates = Array(allDates).sorted(by: >)
    }
    
    
    private func refreshData() async {
        await loadData()
        refreshTrigger = UUID()
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                HeaderView(navigateTo: $navigateTo, section: .list)
                monthSelector
                listContent
                FooterView(navigateTo: $navigateTo, section: .overview)
            }
            .background(.white)
            .task {
                if !hasLoaded {
                    await loadData()
                    hasLoaded = true
                }
            }
            .id(refreshTrigger)
            
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionView(transaction: transaction, create: false, onTransactionChanged: {
                Task {
                    await refreshData()
                }
            })
                .presentationDetents([.fraction(0.97)])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                updateFilteredData()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(formatMonthYear(selectedDate))
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                updateFilteredData()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(68)
        .padding(.horizontal)
        .padding(.top, 8)
    }
        
    private var listContent: some View {
        List {
            ForEach(sortedDates, id: \.self) { date in
                dateSection(for: date)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(.white))
        .scrollContentBackground(.hidden)
    }
    
    private func dateSection(for date: Date) -> some View {
        Section {
            transactionRows(for: date)
        } header: {
            sectionHeader(for: date)
        }
    }
    
    @ViewBuilder
    private func transactionRows(for date: Date) -> some View {
        if let dayTransactions = transactionsByDate[date] {
            
            let sortedTransactions = dayTransactions.sorted { t1, t2 in
                let t1IsExpense = t1.transactionType == .expense || t1.transactionType == .recurring_expense
                let t2IsExpense = t2.transactionType == .expense || t2.transactionType == .recurring_expense
                
                if t1IsExpense != t2IsExpense {
                    return t1IsExpense
                }
                return t1.name < t2.name
            }
            
            
            ForEach(sortedTransactions, id: \.id) { transaction in
                
                transactionRow(transaction)
                    .listRowBackground(Color.white)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .onTapGesture {
                        selectedTransaction = transaction
                    }
            }
        }
    }
    
    private func transactionRow(_ transaction: Transaction) -> some View {
        let isIncome = transaction.transactionType == .income || transaction.transactionType == .recurring_income
        let isRecurring = transaction.transactionType == .recurring_income || transaction.transactionType == .recurring_expense
        
        return HStack(spacing: 12) {
            
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
                    
                    if isRecurring {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if !transaction.description.isEmpty {
                    Text(transaction.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
        
    
    private func sectionHeader(for date: Date) -> some View {
        HStack {
            Text(formatDate(date))
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(.black)
            Spacer()
            totalText(for: date)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets())
    }
    
    private func totalText(for date: Date) -> some View {
        let total = calculateDayTotal(for: date)
        return Text("\(Globals.currencySymbol)\(total, specifier: "%.2f")")
            .font(.headline)
            .fontWeight(.semibold)
            
    }
    
    private func calculateDayTotal(for date: Date) -> Double {
        guard let dayTransactions = transactionsByDate[date] else { return 0 }
        
        var dayTotal: Double = 0
        for transaction in dayTransactions {
            switch transaction.transactionType {
            case .income, .recurring_income:
                dayTotal += Double(transaction.amount)
            case .expense, .recurring_expense:
                dayTotal -= Double(transaction.amount)
            }
        }
        return dayTotal
    }
        
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    
    
    
}


#Preview {
    @State var nav = fTrackerApp.Screen.list
    ListView(navigateTo: $nav)
}

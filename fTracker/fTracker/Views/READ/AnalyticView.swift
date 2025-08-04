import SwiftUI
import Charts

struct AnalyticView: View {
    @Binding var navigateTo: fTrackerApp.Screen
    @Binding var chats: [AIChat.ChatMessage]
    @State private var selectedDate: Date = Date()
    @State private var transactions: [Transaction] = []
    @State private var hasLoaded: Bool = false
    @State private var backgroundHeadCategory: HeadCategoryType = .miscellaneous
    @State private var selectedCategoryAmount: Float = 0
    @State private var showingExpenses: Bool = true
    struct PromptWrapper: Identifiable, Hashable {
        let id = UUID()
        let value: String
    }
    @State private var selectedPrompt: PromptWrapper? = nil
    
    
    
    static public let headCategoryMap: [HeadCategoryType: String] = [
        .entertainment: "gamecontroller.fill",
        .food_and_drinks: "fork.knife",
        .housing: "house.fill",
        .income: "dollarsign.circle",
        .lifestyle: "figure.mind.and.body",
        .miscellaneous: "questionmark.circle.fill",
        .savings: "banknote.fill",
        .transportation : "car.fill"
    ]
    
    init(navigateTo: Binding<fTrackerApp.Screen>, chats: Binding<[AIChat.ChatMessage]>) {
        self._navigateTo = navigateTo
        self._chats = chats
    }
    
    private var filteredExpenseTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            guard let transactionDate = transaction.time else { return false }
            return calendar.isDate(transactionDate, equalTo: selectedDate, toGranularity: .month) &&
            transaction.transactionType == .expense
        }
    }
    
    private var filteredIncomeTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            guard let transactionDate = transaction.time else { return false }
            return calendar.isDate(transactionDate, equalTo: selectedDate, toGranularity: .month) &&
            transaction.transactionType == .income
        }
    }
    
    private var groupedExpenseTransactions: [HeadCategoryType: [Transaction]] {
        filteredExpenseTransactions.reduce(into: [:]) { result, transaction in
            result[transaction.category.headCategory, default: []].append(transaction)
        }
    }
    
    private var groupedIncomeTransactions: [HeadCategoryType: [Transaction]] {
        filteredIncomeTransactions.reduce(into: [:]) { result, transaction in
            result[transaction.category.headCategory, default: []].append(transaction)
        }
    }
    
    
    private var currentGroupedTransactions: [HeadCategoryType: [Transaction]] {
        showingExpenses ? groupedExpenseTransactions : groupedIncomeTransactions
    }
    
    private var categoryToExpenseTransaction: [Int: [Transaction]] {
        filteredExpenseTransactions.reduce(into: [:]) { result, transaction in
            result[transaction.category.id ?? 0, default: []].append(transaction)
        }
    }
    
    private var categoryToIncomeTransaction: [Int: [Transaction]] {
        filteredIncomeTransactions.reduce(into: [:]) { result, transaction in
            result[transaction.category.id ?? 0, default: []].append(transaction)
        }
    }
    
    private var isCurrentGroupedEmpty: Bool {
        for key in currentGroupedTransactions.keys {
            if let count = currentGroupedTransactions[key]?.count, count > 0 {
                return false
            }
        }
        return true
    }
    
        
    private func loadData() async {
        
        let fetchedTransactions = await getTransactions()
        
        
        await MainActor.run {
            self.transactions = fetchedTransactions
            // Initialize with highest category
            updateChartBackground()
        }
    }
    
    private func updateChartBackground() {
        
        let categoryAmounts = currentGroupedTransactions.mapValues { transactions in
            transactions.map(\.amount).reduce(0, +)
        }
        
        if let highestCategory = categoryAmounts.max(by: { $0.value < $1.value }) {
            backgroundHeadCategory = highestCategory.key
            selectedCategoryAmount = highestCategory.value
        } else {
            
            let totalAmount = currentGroupedTransactions.values.flatMap { $0 }.map(\.amount).reduce(0, +)
            selectedCategoryAmount = totalAmount
        }
    }
    
    
    var body: some View {
        VStack {
            header
            ScrollView {
                monthSelector
                donutChart
                barChart
                aiChatMessages
            }
            Spacer()
            FooterView(navigateTo: $navigateTo, section: FooterView.Section.analytic)
        }
        .background(.gray.opacity(0.1))
        .task {
            if !hasLoaded {
                await loadData()
                hasLoaded = true
            }
        }
        .onChange(of: showingExpenses) { _, _ in
            updateChartBackground()
        }
        .onChange(of: selectedDate) { _, _ in
            updateChartBackground()
        }
    }
    
    private var header: some View {
        HStack {
            
        }
        .frame(maxWidth: .infinity, minHeight: 45)
        .background(.purple)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
    
    private var chartToggleButton: some View {
        HStack {
            Button(action: {
                showingExpenses = true
            }) {
                Text("Expenses")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(showingExpenses ? Color.red.opacity(0.2) : Color.clear)
                    .foregroundColor(showingExpenses ? .red : .gray)
                    .cornerRadius(20)
            }
            
            Button(action: {
                showingExpenses = false
            }) {
                Text("Income")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(!showingExpenses ? Color.green.opacity(0.2) : Color.clear)
                    .foregroundColor(!showingExpenses ? .green : .gray)
                    .cornerRadius(20)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var donutChart: some View {
        VStack {
            chartToggleButton
            if isCurrentGroupedEmpty {
                Chart {
                    ForEach(0..<5, id: \.self) { index in
                        SectorMark(
                            angle: .value("Dummy\(index)", Double(50)),
                            innerRadius: .ratio(0.85),
                            angularInset: 2.0
                        )
                        .foregroundStyle(.gray)
                        .cornerRadius(12.0)
                    }
                }
                .frame(height: 300)
                .chartBackground { proxy in
                    VStack(spacing: 4) {
                        Image(systemName:"questionmark.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(.gray)
                        Text("\(Globals.currencySymbol)\(Int(selectedCategoryAmount))")
                            .font(.system(size: 26))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                    }
                }
            } else {
                Chart {
                    ForEach(currentGroupedTransactions.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { key in
                        if let transactions = currentGroupedTransactions[key] {
                            SectorMark(
                                angle: .value(key.rawValue, transactions.map(\.amount).reduce(0, +)),
                                innerRadius: .ratio(0.85),
                                angularInset: 2.0
                            )
                            .foregroundStyle(CategoryView.colorForHeadCategory(key))
                            .cornerRadius(12.0)
                        }
                    }
                }
                .frame(height: 300)
                .chartBackground { proxy in
                    VStack(spacing: 4) {
                        Image(systemName: AnalyticView.headCategoryMap[backgroundHeadCategory] ?? "questionmark.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(CategoryView.colorForHeadCategory(backgroundHeadCategory))
                        Text("\(Globals.currencySymbol)\(Int(selectedCategoryAmount))")
                            .font(.system(size: 26))
                            .font(.headline)
                            .fontWeight(.semibold)
                            
                    }
                }
                .onTapGesture { location in
                    handleChartTap(at: location)
                }
            }
        }
        .frame(width: 350, height: 400)
        .background(.white)
        .cornerRadius(15)
        .padding()
    }
    
    private var barChart: some View {
        VStack {
            chartToggleButton
            
            let currentCategoryTransactions = showingExpenses ? categoryToExpenseTransaction : categoryToIncomeTransaction
            
            if currentCategoryTransactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.gray)
                    
                    Text("No data available")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Add some transactions to see your category breakdown")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(height: 250)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(currentCategoryTransactions.keys.sorted(), id: \.self) { categoryId in
                            if let categoryTransactions = currentCategoryTransactions[categoryId],
                               let firstTransaction = categoryTransactions.first {
                                
                                let totalAmount = categoryTransactions.map(\.amount).reduce(0, +)
                                
                                BarMark(
                                    x: .value("Category", firstTransaction.category.name),
                                    y: .value("Amount", totalAmount)
                                )
                                .foregroundStyle(CategoryView.colorForHeadCategory(firstTransaction.category.headCategory))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(width: max(350, CGFloat(currentCategoryTransactions.count * 80)), height: 250)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text("\(Globals.currencySymbol)\(Int(amount))")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisTick()
                            AxisValueLabel(orientation: .horizontal) {
                                if let categoryName = value.as(String.self) {
                                    Text(categoryName)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(width: 350, height: 400)
        .background(.white)
        .cornerRadius(15)
        .padding()
    }
    
    private var aiChatMessages: some View {
        VStack {
            HStack {
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.blue)
                
                Text("AI Assistant")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding()
            
            HStack {
                Image(systemName: "message.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Can you suggest where I can cut back on spending?")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .onTapGesture {
                selectedPrompt = PromptWrapper(value: "Can you suggest where I can cut back on spending?")
            }
            .padding()
            
            HStack {
                Image(systemName: "message.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Help me set up a monthly budget.")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .onTapGesture {
                selectedPrompt = PromptWrapper(value: "Help me set up a monthly budget.")
            }
            .padding()
            
            HStack {
                Image(systemName: "message.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Was there any overspending this week")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .onTapGesture {
                selectedPrompt = PromptWrapper(value: "Was there any overspending this week")
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width - 40)
        .cornerRadius(15)
        .background(.white)
        .padding()
        .sheet(item: $selectedPrompt) { prompt in
            AIChat(chats: $chats, initMessage: prompt.value)
        }
        .id(selectedPrompt)
    }
    
    private func handleChartTap(at location: CGPoint) {
        
        let sortedKeys = currentGroupedTransactions.keys.sorted(by: { $0.rawValue < $1.rawValue })
        if !sortedKeys.isEmpty {
            if let currentIndex = sortedKeys.firstIndex(of: backgroundHeadCategory) {
                let nextIndex = (currentIndex + 1) % sortedKeys.count
                let nextCategory = sortedKeys[nextIndex]
                backgroundHeadCategory = nextCategory
                if let transactions = currentGroupedTransactions[nextCategory] {
                    selectedCategoryAmount = transactions.map(\.amount).reduce(0, +)
                }
            } else if let firstCategory = sortedKeys.first {
                backgroundHeadCategory = firstCategory
                if let transactions = currentGroupedTransactions[firstCategory] {
                    selectedCategoryAmount = transactions.map(\.amount).reduce(0, +)
                }
            }
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                
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
                
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(68)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
}



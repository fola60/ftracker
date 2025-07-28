import SwiftUI
import Charts

struct ChartView: View {
    
    enum ChartType {
        case income, expense
    }
    
    @State private var transactions: [Transaction] = []
    @State private var cumulativeAmountByDay: [Double] = []
    
    let type: ChartType
    
    private var filteredTransactions: [Transaction] {
        return transactions.filter { transaction in
            switch type {
            case .income:
                return transaction.transactionType == .income || transaction.transactionType == .recurring_income
            case .expense:
                return transaction.transactionType == .expense || transaction.transactionType == .recurring_expense
            }
        }
    }
    
    private var titleText: String {
        switch type {
        case .income:
            return "EARNED THIS MONTH"
        case .expense:
            return "SPENT THIS MONTH"
        }
    }
    
    private var totalAmount: Double {
        guard !cumulativeAmountByDay.isEmpty else { return 0 }
        return cumulativeAmountByDay.last ?? 0
    }
    
    private func loadData() async {
        
        let fetchedTransactions = await getTransactions()
        
        transactions = fetchedTransactions.sorted { transaction1, transaction2 in
            guard let time1 = transaction1.time, let time2 = transaction2.time else {
                return transaction1.time != nil
            }
            return time1 < time2
        }
        
        calculateCumulativeAmounts()
        
    
        
        
    }
    
    private func calculateCumulativeAmounts() {
        let filtered = filteredTransactions
        cumulativeAmountByDay.removeAll()
        
        var cumulativeTotal: Double = 0
        for transaction in filtered {
            cumulativeTotal += Double(transaction.amount)
            cumulativeAmountByDay.append(cumulativeTotal)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(titleText)
                    .foregroundStyle(.gray)
                    .fontWeight(.medium)
                
                if filteredTransactions.count == cumulativeAmountByDay.count && !filteredTransactions.isEmpty {
                    Text("\(Globals.currencySymbol)\(totalAmount, specifier: "%.2f")")
                        .font(.system(size: 32))
                        .fontWeight(.heavy)
                } else {
                    Text("\(Globals.currencySymbol)0")
                        .font(.system(size: 32))
                        .fontWeight(.heavy)
                }
                
                Chart {
                    if filteredTransactions.count == cumulativeAmountByDay.count && !filteredTransactions.isEmpty {
                        ForEach(Array(filteredTransactions.enumerated()), id: \.element.id) { index, transaction in
                            if let time = transaction.time {
                                let day = Calendar.current.component(.day, from: time)
                                LineMark(
                                    x: .value("Day", day),
                                    y: .value("Amount", cumulativeAmountByDay[index])
                                )
                                .lineStyle(StrokeStyle(lineWidth: 5))
                                .foregroundStyle(type == .income ? .green : .red)
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
                .frame(width: 260, height: 120)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
            )
        }
        .task {
            await loadData()
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 40)
        
    }
}

#Preview {
    ChartView(type: .expense)
}

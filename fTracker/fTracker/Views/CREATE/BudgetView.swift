import SwiftUI

struct BudgetView: View {
    @Binding var navigateTo: fTrackerApp.Screen
    @State private var selectedDate: Date = Date()
    @State var budgets: [Budget] = []
    @State var selectedBudget: Budget? = nil
    @State private var isLoaded: Bool = false
    @State private var expenses: [Transaction] = []
    @State private var showingBudgetEditor = false
    @State private var showingBudgetCategoryEditor = false
    @State private var editingCategory: BudgetCategory? = nil
    
    
    struct PromptWrapper: Identifiable {
        let id = UUID()
        let budgetId: Int
        let budgetCategory: BudgetCategory?
        let category: Category
        let isCreate: Bool
    }
    
    @State private var selectedPrompt: PromptWrapper? = nil
    
    private func loadData() async {
        let transactions = await getTransactions()
        budgets = await getBudgets()
        print("Budgets: \(budgets)")
        var tmp: [Transaction] = []
        
        for transaction in transactions {
            if transaction.transactionType == .expense {
                tmp.append(transaction)
            }
        }
        expenses = tmp
        
        
        if selectedBudget == nil && !budgets.isEmpty {
            selectedBudget = budgets.first
        }
        
        isLoaded = true
    }
    
    
    private func refreshBudgetData() async {
        budgets = await getBudgets()
        if let currentBudgetId = selectedBudget?.id {
            selectedBudget = budgets.first { $0.id == currentBudgetId }
        }
    }
    
    private var totalBudgetAmount: Float {
        var total: Float = 0.00
        if let budget = selectedBudget {
            for category in budget.budgetCategories {
                total += category.budgetAmount
            }
        }
        return total
    }
    
    private var filteredExpenses: [Transaction] {
        let calendar = Calendar.current
        return expenses.filter { transaction in
            guard let transactionDate = transaction.time else { return false }
            return calendar.isDate(transactionDate, equalTo: selectedDate, toGranularity: .month)
        }
    }
    
    private var totalSpent: Float {
        var total: Float = 0.00
        for expense in filteredExpenses {
            total += expense.amount
        }
        return total
    }
    
    private var balance: Float {
        return totalBudgetAmount - totalSpent
    }
    
    
    private var groupedCategories: [HeadCategoryType: [BudgetCategory]] {
        guard let budget = selectedBudget else { return [:] }
        
        var grouped: [HeadCategoryType: [BudgetCategory]] = [:]
        for category in budget.budgetCategories {
            let headCategory = category.categoryId.headCategory
            if grouped[headCategory] == nil {
                grouped[headCategory] = []
            }
            grouped[headCategory]?.append(category)
        }
        return grouped
    }
    
    
    private func spentAmount(for budgetCategory: BudgetCategory) -> Float {
        let categoryExpenses = filteredExpenses.filter { expense in
            expense.category.id == budgetCategory.categoryId.id
        }
        return categoryExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack {
            header
            ScrollView {
                
                monthSelector
                VStack(spacing: 20) {
                    if let budget = selectedBudget {
                        if !budget.budgetCategories.isEmpty {
                            ForEach(Array(groupedCategories.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { headCategory in
                                categorySection(for: headCategory, categories: groupedCategories[headCategory] ?? [])
                            }
                        } else {
                            
                            emptyBudgetCategoriesView
                        }
                    } else {
                        emptyBudgetView
                    }
                }
                .padding()
            }
            
            FooterView(navigateTo: $navigateTo, section: .budget)
        }
        .task {
            if !isLoaded {
                await loadData()
            }
        }
        .sheet(item: $selectedPrompt) { prompt in
            BudgetCategoryView(budgetId: prompt.budgetId, budgetCategory: prompt.budgetCategory, category: prompt.category, isCreate: prompt.isCreate)
                .presentationDetents([.fraction(0.93)])
                .onDisappear {
                    Task {
                        await refreshBudgetData()
                    }
                }
        }
        .sheet(isPresented: $showingBudgetEditor) {
            BudgetEditView(budgets: $budgets, selectedBudget: $selectedBudget)
                .presentationDetents([.fraction(0.67)])
        }
        
        
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            budgetSelector
            progressHeader
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(.green)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
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
        .background(.gray.opacity(0.1))
        .cornerRadius(68)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private var budgetSelector: some View {
        HStack {
            
            Button {
                showingBudgetEditor = true
            } label: {
                HStack {
                    Text(selectedBudget?.name ?? "Select Budget")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.green)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var progressHeader: some View {
        let progressValue = totalBudgetAmount == 0 ? 0.0 : Float(totalSpent / totalBudgetAmount)
        return ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .foregroundColor(.blue)
                .opacity(0.2)
            
            Circle()
                .trim(from: 0.0, to: min(CGFloat(progressValue), 1.0))
                .stroke(AngularGradient(colors: [.yellow, .orange, .pink, .red], center: .center),
                       style: StrokeStyle(lineWidth: 12, lineCap: .butt, lineJoin: .miter))
            
            VStack {
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.primary)
                
                Text("\(Globals.currencySymbol)\(abs(Int(balance)))")
                    .font(.system(size: 26))
                    .fontWeight(.heavy)
                    .foregroundStyle(balance >= 0 ? .white : .red)
                Text(balance >= 0 ? "Left to spend" : "Over budget")
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            
        }
        .frame(width: 200, height: 200)
        .padding()
    }
    
    private var dateSelector: some View {
        DatePicker(
            "Select Month",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func totalBudgetHeadCategoryAmount(headCategoryType: HeadCategoryType) -> Float {
        var total: Float = 0.00
        
        if let budget = selectedBudget {
            for budgetCategory in budget.budgetCategories {
                if budgetCategory.categoryId.headCategory == headCategoryType {
                    total += budgetCategory.budgetAmount
                }
            }
        }
        
        return total
    }
    
    private func totalHeadCategorySpending(headCategoryType: HeadCategoryType) -> Float {
        var total: Float = 0.00
        
        for expense in filteredExpenses {
            if expense.category.headCategory == headCategoryType {
                total += expense.amount
            }
        }
        
        return total
    }
    
    private func categorySection(for headCategory: HeadCategoryType, categories: [BudgetCategory]) -> some View {
        let headCategoryBalance: Float = totalBudgetHeadCategoryAmount(headCategoryType: headCategory) - totalHeadCategorySpending(headCategoryType: headCategory)
        return VStack(alignment: .leading, spacing: 15) {
            
            HStack {
                Text(headCategoryDisplayName(headCategory))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Globals.currencySymbol)\(abs(Int(headCategoryBalance))) \(headCategoryBalance >= 0 ? "Left" : "Over")")
                    .font(.system(size: 16))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(headCategoryBalance >= 0 ? .green.opacity(0.5) : .red.opacity(0.5))
            }
            
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(categories, id: \.id) { category in
                    categoryCard(for: category)
                }
            }
            
            HStack {
                Button {
                    Task {
                        let defaultCategory = await Globals.getDefaultCategory()
                        selectedPrompt = PromptWrapper(budgetId: selectedBudget?.id ?? -1, budgetCategory: nil, category: defaultCategory, isCreate: true)
                    }
                } label: {
                     Text("Add category")
                        .font(.caption)
                        .foregroundStyle(.blue.opacity(0.8))
                }
            }
            .padding()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        
    }
    
    private func categoryCard(for budgetCategory: BudgetCategory) -> some View {

        let spent = spentAmount(for: budgetCategory)
        let budgetAmount = budgetCategory.budgetAmount
        let progress = budgetAmount == 0 ? 0.0 : spent / budgetAmount
        
        return VStack(spacing: 10) {
            // Circular progress view
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .foregroundColor(.gray)
                    .opacity(0.2)
                
                Circle()
                    .trim(from: 0.0, to: min(CGFloat(progress), 1.0))
                    .stroke(progressColor(for: progress), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Image(systemName: CategoryView.categoryIconMap[budgetCategory.categoryId.name] ?? "eurosign.bank.building")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(CategoryView.colorForHeadCategory(budgetCategory.categoryId.headCategory))
                    
                    Text("\(Globals.currencySymbol)\(Int(budgetAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)
            
            
            VStack(spacing: 4) {
                Text(budgetCategory.categoryId.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("Remaining: \(Globals.currencySymbol)\(Int(budgetAmount - spent))")
                    .font(.caption)
                    .foregroundColor(budgetAmount - spent >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture {
            selectedPrompt = PromptWrapper(budgetId: selectedBudget?.id ?? 0, budgetCategory: budgetCategory, category: budgetCategory.categoryId, isCreate: false)
        }
    }
    
    private var emptyBudgetView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Budget Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create or select a budget to start tracking your expenses")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Budget") {
                showingBudgetEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    
    private var emptyBudgetCategoriesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Categories")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add categories to your budget to start tracking your expenses")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Category") {
                Task {
                    let defaultCategory = await Globals.getDefaultCategory()
                    selectedPrompt = PromptWrapper(budgetId: selectedBudget?.id ?? -1, budgetCategory: nil, category: defaultCategory, isCreate: true)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func headCategoryDisplayName(_ category: HeadCategoryType) -> String {
        switch category {
        case .entertainment:
            return "Entertainment"
        case .food_and_drinks:
            return "Food & Drinks"
        case .housing:
            return "Housing"
        case .income:
            return "Income"
        case .lifestyle:
            return "Lifestyle"
        case .miscellaneous:
            return "Miscellaneous"
        case .savings:
            return "Savings"
        case .transportation:
            return "Transportation"
        }
    }
    
    private func progressColor(for progress: Float) -> Color {
        if progress <= 0.7 {
            return .green
        } else if progress <= 0.9 {
            return .orange
        } else {
            return .red
        }
    }
}

struct BudgetEditView: View {
    enum FocusedField {
        case str1
    }
    
    @Binding var budgets: [Budget]
    @Binding var selectedBudget: Budget?
    @State private var isCreating: Bool = false
    @State private var name: String = ""
    @State private var showingDeleteAlert = false
    @State private var budgetToDelete: Budget? = nil
    @FocusState private var focusedField: FocusedField?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                headerView
                
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        
                        ForEach(budgets, id: \.id) { budget in
                            budgetRow(budget)
                        }
                        
                        createBudgetSection
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .alert("Delete Budget", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                budgetToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let budget = budgetToDelete {
                    Task {
                        await delete(budget.id ?? -1)
                    }
                }
                budgetToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this budget? This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Manage Budgets")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private func budgetRow(_ budget: Budget) -> some View {
        HStack(spacing: 16) {
            
            Image(systemName: "house.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(budget.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(budget.budgetCategories.count) categories")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            
            if selectedBudget?.id == budget.id {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            
            Button {
                budgetToDelete = budget
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            if !isCreating {
                selectedBudget = budget
                dismiss()
            }
        }
    }
    
    private var createBudgetSection: some View {
        VStack(spacing: 12) {
            if !isCreating {
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isCreating = true
                        focusedField = .str1
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Create New Budget")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: "house.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        TextField("Budget Name", text: $name)
                            .focused($focusedField, equals: .str1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                if !name.isEmpty {
                                    Task {
                                        await save()
                                    }
                                }
                            }
                    }
                    
                    
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isCreating = false
                                name = ""
                                focusedField = nil
                            }
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Cancel")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            if !name.isEmpty {
                                Task {
                                    await save()
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Create")
                            }
                            .font(.headline)
                            .foregroundColor(name.isEmpty ? .gray : .green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((name.isEmpty ? Color.gray : Color.green).opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(name.isEmpty)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private func delete(_ id: Int) async {
        let _ = await deleteBudget(id)
        
        if let index = budgets.firstIndex(where: { $0.id == id }) {
            budgets.remove(at: index)
        }
        
        if selectedBudget?.id == id {
            selectedBudget = budgets.first
        }
    }
    
    
    private func save() async {
        let newBudget = await postBudget(budget: BudgetRequest(id: nil, name: name, user_id: Globals.userId))
        if let budget = newBudget {
            budgets.append(budget)
            selectedBudget = budget
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isCreating = false
            name = ""
            focusedField = nil
        }
        
        dismiss()
    }
}

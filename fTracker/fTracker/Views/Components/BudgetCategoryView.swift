import SwiftUI

struct BudgetCategoryView: View {
    
    @State var budgetId: Int
    @State var budgetCategory: BudgetCategory?
    @State var category: Category
    @State var isCreate: Bool
    @State private var isLoaded: Bool = false
    @State private var amount: Float = 0.00
    @State private var showKeypad: Bool = false
    @State private var showCategory: Bool = false
    @Environment(\.dismiss) var dismiss
    
    
    private func loadData() async {
        dump(budgetCategory)
        if let budgetCategory = budgetCategory {
            amount = budgetCategory.budgetAmount
            category = budgetCategory.categoryId
        }
        
        isLoaded = true
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(isCreate ? "Create" : "Update") Budget Category")
            }
            .font(.system(size: 26))
            .fontWeight(.light)
            .foregroundStyle(.gray)
            .padding()
            
            
            Text("\(Globals.currencySymbol)\(String(format: "%.2f", amount))")
                .font(.system(size: 48))
                .foregroundStyle(.green.opacity(0.7))
                .fontWeight(.heavy)
                .padding()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showKeypad = true
                    }
                }
                .blur(radius: showKeypad ? 5 : 0)
                .disabled(showKeypad)
            
            HStack {
                Image(systemName: CategoryView.categoryIconMap[category.name] ?? "eurosign.bank.building")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading)
                    .foregroundStyle(CategoryView.colorForHeadCategory(category.headCategory))
                Text("Category: ")
                Text(category.name)
                    .foregroundStyle(CategoryView.colorForHeadCategory(category.headCategory))
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
                if !isCreate {
                    Button {
                        Task {
                            await deleteBudgetCategoryLocal()
                            dismiss()
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
                        await saveBudgetCategoryLocal()
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .foregroundStyle(.white)
                        .font(.system(size: 24))
                        .frame(width: isCreate ? 380 : 280, height: 45)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
            
            
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
            Spacer()
        }
        .task {
            if !isLoaded {
                await loadData()
            }
        }
    }
    
    private func deleteBudgetCategoryLocal() async {
        if let budgetCategory = budgetCategory {
            let _ = await deleteBudgetCategory(budgetCategory.id)
        } 
    }
    
    private func saveBudgetCategoryLocal() async {
        print("Save budget category called.")
        if let budgetCategory = budgetCategory {
            let budgetCategoryRequest = BudgetCategoryRequest(id: budgetCategory.id, budget_id: budgetId, amount: amount, category_id: budgetCategory.categoryId.id ?? -1)
            let _ = await postBudgetCategory(budgetCategory: budgetCategoryRequest)
        } else {
            let budgetCategoryRequest = BudgetCategoryRequest(id: nil, budget_id: budgetId, amount: amount, category_id: category.id ?? -1)
            let _ = await postBudgetCategory(budgetCategory: budgetCategoryRequest)
        }
    }
}

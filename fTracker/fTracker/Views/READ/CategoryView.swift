import SwiftUI

struct CategoryView: View {
    @Binding var category: Category
    @State private var userCategories: [Category] = []
    static public let categoryIconMap = [
        "Salary":"eurosign.arrow.trianglehead.counterclockwise.rotate.90",
        "Savings":"banknote.fill",
        "Rent":"house.fill",
        "Electricity":"bolt.fill",
        "Internet":"wifi",
        "Telephone":"phone.fill",
        "Tv":"tv.fill",
        "Restaurant":"fork.knife",
        "Groceries":"cart.fill",
        "Cloths":"tshirt.fill",
        "Gym":"dumbbell.fill",
        "Public Transport":"tram.fill",
        "Vehicle":"fuelpump.fill",
        "Miscellaneous": "eurosign.bank.building"
    ]
    @Environment(\.dismiss) var dismiss
    
    
    public static func colorForHeadCategory(_ headCategory: HeadCategoryType) -> Color {
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
    
    
    private var groupedCategories: [HeadCategoryType: [Category]] {
        Dictionary(grouping: userCategories, by: { $0.headCategory })
    }
    
    var body: some View {
        NavigationView {
            categoryListView
                .navigationTitle("Select Category")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        cancelButton
                    }
                }
        }
        .onAppear {
            Task {
                
                userCategories = await getCategories()
            }
        }
    }
    
    private var categoryListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(HeadCategoryType.allCases, id: \.self) { headCategory in
                    categorySection(for: headCategory)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func categorySection(for headCategory: HeadCategoryType) -> some View {
        Group {
            if let categories = groupedCategories[headCategory], !categories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(for: headCategory)
                    categoryGrid(for: categories, headCategory: headCategory)
                }
            }
        }
    }
    
    private func sectionHeader(for headCategory: HeadCategoryType) -> some View {
        let displayName = headCategory.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        
        return Text(displayName)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(CategoryView.colorForHeadCategory(headCategory))
            .padding(.horizontal)
    }
    
    private func categoryGrid(for categories: [Category], headCategory: HeadCategoryType) -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories, id: \.id) { cat in
                categoryItem(for: cat, headCategory: headCategory)
            }
        }
        .padding(.horizontal)
    }
    
    private func categoryItem(for cat: Category, headCategory: HeadCategoryType) -> some View {
        let iconName = CategoryView.categoryIconMap[cat.name] ?? "questionmark.circle.fill"
        let backgroundColor = CategoryView.colorForHeadCategory(headCategory)
        
        return CategoryItemView(
            category: cat,
            iconName: iconName,
            backgroundColor: backgroundColor
        ) {
            selectCategory(cat)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private func selectCategory(_ selectedCategory: Category) {
        self.category = selectedCategory
        dismiss()
    }
}

struct CategoryItemView: View {
    let category: Category
    let iconName: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(backgroundColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


extension HeadCategoryType: CaseIterable {
    public static var allCases: [HeadCategoryType] {
        return [.income, .savings, .housing, .food_and_drinks, .transportation, .entertainment, .lifestyle, .miscellaneous]
    }
}

#Preview {
    @Previewable @State var category_new = Category(id: Globals.userId, headCategory: .entertainment, name: "Movies")
    return CategoryView(category: $category_new)
}

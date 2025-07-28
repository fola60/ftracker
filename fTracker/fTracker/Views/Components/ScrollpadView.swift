import SwiftUI

struct ScrollpadView: View {
    @Binding var time_recurring: Int?
    
    private let options: [Int?] = [nil, 1, 7, 14, 30, 60, 90, 365]
    private let dayToStringMap: [Int?: String] = [
        nil: "Never Repeat",
        1: "Every Day",
        7: "Every Week",
        14: "Every other week",
        30: "Every month",
        60: "Every other month",
        90: "Every 3 months",
        365: "Every year"
    ]
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select Recurrence")
                    .font(.headline)
                    .padding()
                
                Picker("Time Recurring", selection: $selectedIndex) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Text(dayToStringMap[options[index]] ?? "Every \(options[index] ?? 0) days")
                            .tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 200)
                .clipped()
                
                Spacer()
            }
            .onAppear {
                // Set initial selected index based on current value
                if let currentValue = time_recurring,
                   let index = options.firstIndex(of: currentValue) {
                    selectedIndex = index
                } else {
                    selectedIndex = 0
                }
            }
            .onChange(of: selectedIndex) { newIndex in
                time_recurring = options[newIndex]
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    @Previewable @State var time_re: Int? = nil
    ScrollpadView(time_recurring: $time_re)
}

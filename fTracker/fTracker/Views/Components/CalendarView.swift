import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var showingDatePicker = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        HStack {
            
            Button(action: {
                showingDatePicker.toggle()
            }) {
                Text(Calendar.current.isDateInToday(selectedDate) ? "Today" : dateFormatter.string(from: selectedDate))
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, isPresented: $showingDatePicker)
        }
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

// Example usage in parent view
struct ParentView: View {
    @State private var time = Date()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.leading)
                CalendarView(selectedDate: $time)
                Spacer()
            }
            .padding()
            
            // Your other content here
            Text("Selected date: \(time, style: .date)")
                .padding()
        }
    }
}

#Preview {
    @State var now = Date()
    @State var isPresented = true
    CalendarView(selectedDate: $now)
}

import SwiftUI

struct KeypadView: View {
    @Binding var amount: Float
    @Binding var isPresented: Bool

    @State private var input: String = ""

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    if let val = Float(input) {
                        amount = val
                    }
                    isPresented = false
                }) {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
                
            VStack {
                Text("\(Globals.currencySymbol)\(String(format: "%.2f", amount))")
            }
            
            let buttons = [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                [".", "0", "⌫"]
            ]

            VStack(spacing: 12) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 16) {
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                handleInput(item)
                            }) {
                                Text(item)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    private func handleInput(_ key: String) {
        switch key {
        case "⌫":
            if !input.isEmpty {
                input.removeLast()
            }
        case ".":
            if !input.contains(".") {
                input.append(".")
            }
        default:
            input.append(key)
        }
        
        if let val = Float(input) {
            amount = val
        } else if input.isEmpty {
            amount = 0.0
        }
    }
}

#Preview {
    @Previewable @State var present = true
    @Previewable @State var db: Float = 0.00
    KeypadView(amount: $db, isPresented: $present)
}

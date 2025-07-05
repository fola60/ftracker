//
//  CreateBySpeech.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 21/06/2025.
//
import SwiftUI

@MainActor
struct AIChat: View {
    enum FocusedField {
        case str1
    }
    
    enum MessageSender {
        case user
        case ai
    }
    
    enum ChatContent {
        case text(String)
        case view(AnyView)
        case transcation(DisplayStatement)
    }
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let sender: MessageSender
        let content: ChatContent
    }
    
    @StateObject private var expenses: Expenses = Expenses()
    @StateObject private var incomes: Incomes = Incomes()
    @StateObject private var recurringCharges: RecurringCharges = RecurringCharges()
    @StateObject private var recurringRevenues: RecurringRevenues = RecurringRevenues()
    @State private var responses: Array<SpeechResponse> = []
    @StateObject var whisperState = WhisperState()
    @State var success: Bool = false
    @State var isProcessing: Bool = false
    @State var chats: [ChatMessage] = [
        ChatMessage(sender: .ai, content: .text("What can I help you with? I can create and delete transactions and help you plan how to better manage your finances."))
    ]
    @State var text: String = ""
    @FocusState var focusedField: FocusedField?
    
    
    var body: some View {
        /*
        NavigationView {
            VStack {
                HStack {
                    Button {
                        Task {
                            await toggleRecord()
                        }
                    } label: {
                        Image(systemName: whisperState.isRecording ? "waveform.circle" : "microphone.circle.fill")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .foregroundColor(whisperState.isRecording ? .green : .orange)
                            .symbolEffect(.breathe, isActive: whisperState.isRecording)
                    }
                    .disabled(!whisperState.canTranscribe || isProcessing)
                }
                HStack {
                    if !isProcessing {
                        NavigationLink(destination: ConfirmStatements(expenses: expenses, incomes: incomes, recurringCharges: recurringCharges, recurringRevenues: recurringRevenues)) {
                            Text("Confirm")
                                .font(.system(size: 32))
                                .foregroundStyle(success ? .green : .gray.opacity(0.4))
                                .fontWeight(.medium)
                        }
                        .disabled(!whisperState.canTranscribe || isProcessing || !success || responses.isEmpty)
                    } else {
                        ProgressView("Processing...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut, value: isProcessing)
                    }
                    
                }
            }
            .navigationTitle("Add finaces by speech")
        }
         */
        ScrollView {
            Spacer()
                .frame(height: 30)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(chats) { message in
                    switch message.content {
                    case .text(let text):
                        HStack {
                            if message.sender == .user {
                                Spacer()
                            }
                            Text(text)
                                .padding()
                                .background(message.sender == .user ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                                .cornerRadius(10)
                            if message.sender == .ai {
                                Spacer()
                            }
                        }
                    case .view(let view):
                        view
                    case .transcation(let displayStatement):
                        displayStatement
                    }
                }
                .padding()
            }
        }
        .background(.white)
        HStack {
            TextField("Create a new expense called ...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .str1)
                
            Button("Send") {
                Task {
                    let userMessage = ChatMessage(sender: .user, content: .text(text))
                    chats.append(userMessage)
                    await processSpeechRequest(request: text)
                    text = ""
                }
            }
        }
        .padding(.horizontal)
    
    }
    
    
    func toggleRecord() async {
        await whisperState.toggleRecord()
        if !whisperState.isRecording {
            let text = whisperState.transcribedAudio
            print("??? \(text) ???")
            isProcessing = true
            await processSpeechRequest(request: text)
            isProcessing = false
        }
    }
    
    
    func processSpeechRequest(request: String) async {
        do {
            print("Requesting ai: ", request)
            responses = try await getSpeechFinanceRequest(speech_text: request)
            success = responses.count > 0
            print(responses)
            for response in responses {
                switch response.type {
                case .income:
                    incomes.results = Incomes(responses: response.income!).results
                    for (index, income) in incomes.results.enumerated() {
                        chats.append(ChatMessage(
                            sender: .ai,
                            content: .transcation(
                                DisplayStatement(
                                    removeStatement: {
                                        _,_ in incomes.results.remove(at: index)
                                        if let chatIndex = chats.firstIndex(where: {
                                            if case .transcation(let ds) = $0.content {
                                                return ds.id == index && ds.type == .recurring_charge
                                            }
                                                return false
                                            }) {
                                            chats.remove(at: chatIndex)
                                        }
                                    },
                                    expense: nil,
                                    income: income,
                                    recurringCharge: nil,
                                    recurringRevenue: nil,
                                    id: index,
                                    type: .income
                                )
                            )
                        ))
                    }
                    dump(incomes.results)
                case .expense:
                    expenses.results = Expenses(responses: response.expense!).results
                    for (index, expense) in expenses.results.enumerated() {
                        chats.append(ChatMessage(
                            sender: .ai,
                            content: .transcation(
                                DisplayStatement(
                                    removeStatement: {_,_ in
                                        // expenses.results.remove(at: index)
                                        if let chatIndex = chats.firstIndex(where: {
                                            if case .transcation(let ds) = $0.content {
                                                return ds.id == index && ds.type == .recurring_charge
                                            }
                                                return false
                                            }) {
                                            chats.remove(at: chatIndex)
                                        }
                                    },
                                    expense: expense,
                                    income: nil,
                                    recurringCharge: nil,
                                    recurringRevenue: nil,
                                    id: index,
                                    type: .expense
                                )
                            )
                        ))
                    }
                    dump(expenses.results)
                case .recurring_charge:
                    recurringCharges.results = RecurringCharges(responses: response.recurringCharge!).results
                    for (index, recurringCharge) in recurringCharges.results.enumerated() {
                        chats.append(ChatMessage(
                            sender: .ai,
                            content: .transcation(
                                DisplayStatement(
                                    removeStatement: {
                                        _,_ in recurringCharges.results.remove(at: index)
                                        if let chatIndex = chats.firstIndex(where: {
                                            if case .transcation(let ds) = $0.content {
                                                return ds.id == index && ds.type == .recurring_charge
                                            }
                                                return false
                                            }) {
                                            chats.remove(at: chatIndex)
                                        }
                                    },
                                    expense: nil,
                                    income: nil,
                                    recurringCharge: recurringCharge,
                                    recurringRevenue: nil,
                                    id: index,
                                    type: .recurring_charge
                                )
                            )
                        ))
                    }
                    dump(recurringCharges.results)
                case .recurring_revenue:
                    recurringRevenues.results = RecurringRevenues(responses: response.recurringRevenue!).results
                    for (index, recurringRevenue) in recurringRevenues.results.enumerated() {
                        chats.append(ChatMessage(
                            sender: .ai,
                            content: .transcation(
                                DisplayStatement(
                                    removeStatement: {
                                        _,_ in recurringRevenues.results.remove(at: index)
                                        if let chatIndex = chats.firstIndex(where: {
                                            if case .transcation(let ds) = $0.content {
                                                return ds.id == index && ds.type == .recurring_charge
                                            }
                                                return false
                                            }) {
                                            chats.remove(at: chatIndex)
                                        }
                                    },
                                    expense: nil,
                                    income: nil,
                                    recurringCharge: nil,
                                    recurringRevenue: recurringRevenue,
                                    id: index,
                                    type: .recurring_revenue
                                )
                            )
                        ))
                    }
                    dump(recurringRevenues.results)
                case .error:
                    print("AI returned error message")
                    chats.append(ChatMessage(
                        sender: .ai,
                        content: .text("Sorry, I cant Help you with that")
                    ))
                    success = false
                }
            }
            
        } catch {
            print("Error processing speech request:", error)
            success = false
        }
    }
    
    struct ConfirmStatements: View {
        @ObservedObject var expenses: Expenses
        @ObservedObject var incomes: Incomes
        @ObservedObject var recurringCharges: RecurringCharges
        @ObservedObject var recurringRevenues: RecurringRevenues
        @State private var isExpanded: Bool = false
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            
            ZStack {
                VStack {
                    Spacer()
                        .frame(maxHeight: 20)
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(maxHeight: 20)
                        ForEach( Array(expenses.results.enumerated()), id: \.offset ) {index, expense in
                            DisplayStatement(removeStatement: {_,_ in removeStatement(index: index, type: ItemType.expense)
                            }, expense: expense, income: nil, recurringCharge: nil, recurringRevenue: nil, id: index, type: ItemType.expense)
                        }
                        ForEach( Array(incomes.results.enumerated()), id: \.offset ) {index, income in
                            DisplayStatement(removeStatement: {_,_ in removeStatement(index: index, type: ItemType.income)
                            }, expense: nil, income: income, recurringCharge: nil, recurringRevenue: nil, id: index, type: ItemType.income)
                        }
                        ForEach( Array(recurringCharges.results.enumerated()), id: \.offset ) {index, recurringCharge in
                            DisplayStatement(removeStatement: {_,_ in removeStatement(index: index, type: ItemType.recurring_charge)
                            }, expense: nil, income: nil, recurringCharge: recurringCharge, recurringRevenue: nil, id: index, type: ItemType.recurring_charge)
                        }
                        ForEach( Array(recurringRevenues.results.enumerated()), id: \.offset ) {index, recurringRevenue in
                            DisplayStatement(removeStatement: {_,_ in removeStatement(index: index, type: ItemType.recurring_revenue)
                            }, expense: nil, income: nil, recurringCharge: nil, recurringRevenue: recurringRevenue, id: index, type: ItemType.recurring_revenue)
                        }
                    }
                    Button {
                        Task {
                            await submitStatements()
                        }
                    } label: {
                        Text("Submit")
                    }
                }
                .padding()
            }
            .padding()
        }
        
        
        func removeStatement(index: Int, type: ItemType) {
            
            switch type {
            case .expense:
                expenses.results.remove(at: index)
            case .income:
                incomes.results.remove(at: index)
            case .recurring_charge:
                recurringCharges.results.remove(at: index)
            case .recurring_revenue:
                recurringRevenues.results.remove(at: index)
            case .error:
                print("error")
            }
            
        }
        
        @MainActor
        func submitStatements() async {
            for expense in expenses.results {
                let _ = await postExpense(expense: expense)
            }
            expenses.results = []
            
            for income in incomes.results {
                let _ = await postIncome(income: income)
            }
            incomes.results = []
            
            for recurringRevenue in recurringRevenues.results {
                let _ = await postRecurringRevenue(recurringRevenue: recurringRevenue)
            }
            recurringRevenues.results = []
            
            for recurringCharge in recurringCharges.results {
                let _ = await postRecurringCharge(recurringCharge: recurringCharge)
            }
            recurringCharges.results = []
            
        }
    }
    
    
    
}

#Preview {
    AIChat()
}

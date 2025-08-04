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
        case transcation(ChatDisplayTransaction)
    }
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let sender: MessageSender
        let content: ChatContent
    }
    
    @State private var responses: Array<SpeechResponse> = []
    @StateObject var whisperState = WhisperState()
    @State var success: Bool = false
    @State var isProcessing: Bool = false
    @State var text: String = ""
    @State var isLoaded: Bool = false
    @FocusState var focusedField: FocusedField?
    @Binding var chats: [ChatMessage]
    @State var initMessage: String
    
    private func loadData() async {
        print("init message: \(initMessage)")
        if initMessage.count < 4 {
            return
        }
        chats.append(ChatMessage(sender: .user, content: .text(initMessage)))
        isProcessing = true
        let _ = await processSpeechRequest(request: initMessage)
        isProcessing = false
        
    }
    
    var body: some View {
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
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 5)
            .background(.ultraThinMaterial)
            
            ScrollView {
                Spacer()
                    .frame(height: 30)
                VStack(alignment: .leading, spacing: 10) {
                    
                    if chats.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .resizable()
                                .frame(width: 50, height: 40)
                                .foregroundColor(.blue.opacity(0.6))
                            
                            Text("Welcome to AI Assistant")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("I can help you create transactions, check your spending, and answer questions about your finances.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 40)
                    }
                    
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
            
            if isProcessing {
                HStack {
                    ProgressView("Processing...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut, value: isProcessing)
                }
                .padding(.horizontal)
            }
            
            HStack {
                TextField("Create a new expense called ...", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .str1)
                
                
                Button {
                    Task {
                        await toggleRecord()
                    }
                } label: {
                    Image(systemName: whisperState.isRecording ? "waveform.circle" : "microphone.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(whisperState.isRecording ? .green : .orange)
                        .symbolEffect(.breathe, isActive: whisperState.isRecording)
                }
                .disabled(!whisperState.canTranscribe || isProcessing)
                    
                Button("Send") {
                    Task {
                        let userMessage = ChatMessage(sender: .user, content: .text(text))
                        chats.append(userMessage)
                        let tmpText = text
                        text = ""
                        await processSpeechRequest(request: tmpText)
                    }
                }
                .disabled(text.isEmpty || isProcessing)
            }
            .padding(.horizontal)
        }
        .task {
            if !isLoaded {
                await loadData()
                isLoaded = true
            }
        }
    }
    
    
    func toggleRecord() async {
        await whisperState.toggleRecord()
        if !whisperState.isRecording {
            let transcribedText = whisperState.transcribedAudio
            
            if !transcribedText.isEmpty {
                isProcessing = true
                let userMessage = ChatMessage(sender: .user, content: .text(transcribedText))
                chats.append(userMessage)
                await processSpeechRequest(request: transcribedText)
                isProcessing = false
                
                whisperState.transcribedAudio = ""
            }
        }
    }
    
    
    func processSpeechRequest(request: String) async {
        do {
            print("Requesting ai: ", request)
            isProcessing = true
            responses = try await getSpeechFinanceRequest(speech_text: request, chats: chats)
            success = responses.count > 0
            print(responses)
            for response in responses {
                switch response.type {
                case .BUDGET:
                    if let actionText = response.action {
                        chats.append(
                            ChatMessage(sender: .ai, content: .text(actionText))
                        )
                    }
                case .TRANSACTION:
                    if let actionText = response.action {
                        chats.append(
                            ChatMessage(sender: .ai, content: .text(actionText))
                        )
                    }
                    if let action = response.action_type {
                        if ![.CREATE, .READ, .UPDATE].contains(action) {
                            break
                        }
                        if let transaction_id = response.transaction_id {
                            if let transaction = await getTransaction(transaction_id) {
                                chats.append(
                                    ChatMessage(sender: .ai, content: .transcation(ChatDisplayTransaction(transaction: transaction)))
                                )
                            }
                        }
                    }
                case .INFO:
                    if let actionText = response.action {
                        chats.append(
                            ChatMessage(sender: .ai, content: .text(actionText))
                        )
                    }
                    
                    if let transactions = response.transaction {
                        for transaction in transactions {
                            chats.append(
                                ChatMessage(sender: .ai, content:
                                        .transcation(ChatDisplayTransaction(transaction: transaction))
                                )
                            )
                        }
                    }
                case .ERROR:
                    if let actionText = response.error_message {
                        chats.append(
                            ChatMessage(sender: .ai, content: .text(actionText))
                        )
                    }
                }
            }
            isProcessing = false
        } catch {
            print("Error processing speech request:", error)
            success = false
        }
    }
    
    
        
        
        
    
    
    struct ChatDisplayTransaction: View {
        @State var transaction: Transaction
        @State private var showTransactionView = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Transaction")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.name)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("\(Globals.currencySymbol)\(transaction.amount, specifier: "%.2f")")
                            .font(.body)
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                        
                        
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .onTapGesture {
                showTransactionView = true
            }
            .sheet(isPresented: $showTransactionView) {
                NavigationView {
                    TransactionView(transaction: transaction, create: false)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    showTransactionView = false
                                }
                            }
                        }
                }
            }
        }
    }
    
}

#Preview {
    @Previewable @State var chats: [AIChat.ChatMessage] = []
    AIChat(chats: $chats, initMessage: "")
}

//
//  LandingPage.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 01/07/2025.
//

import SwiftUI


struct LandingPage: View {
    
    
    @Binding var navigateTo: fTrackerApp.Screen
    @State var chats: [AIChat.ChatMessage] = []
    @State var showTransactionSheet: Bool = false
    @State var showAiChatSheet: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HeaderView(navigateTo: $navigateTo, section: HeaderView.Section.overview)

                ScrollView {
                    ChartView(type: .expense)
                }

                Spacer()
                FooterView(navigateTo: $navigateTo, section: FooterView.Section.overview)
            }
            .background(.gray.opacity(0.1))

            HStack {
                // Ask AI Button VStack
                VStack {
                    HStack {
                        Image(systemName: "message.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        
                        Text("Ask AI")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
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
                    
                    Text("Get insights about your spending")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                .frame(maxWidth: 200, alignment: .leading)
                .padding(.leading, 20)
                .padding(.bottom, 70)
                .onTapGesture {
                    showAiChatSheet = true
                }
                .sheet(isPresented: $showAiChatSheet) {
                    AIChat(chats: $chats, initMessage: "")
                        .presentationDetents([.fraction(0.97)])
                        .presentationDragIndicator(.hidden)
                }
                Spacer()
                // Plus Button VStack
                VStack {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 95)
                .onTapGesture {
                    showTransactionSheet = true
                }
                .sheet(isPresented: $showTransactionSheet) {
                    TransactionView(transaction: nil, create: true)
                        .presentationDetents([.fraction(0.97)])
                        .presentationDragIndicator(.hidden)
                }
            }
        }
    }
    
    private var recentTransactions: any View {
        HStack {
            
        }
    }
}


#Preview {
    @Previewable @State var section: fTrackerApp.Screen = .landing
    LandingPage(navigateTo: $section)
}

//
//  fTrackerApp.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//

import SwiftUI

@main
struct fTrackerApp: App {
    @State private var currentScreen: Screen = .landing
    @State private var chats: [AIChat.ChatMessage] = []
    enum Screen {
        case landing
        case list
        case analytics
        case tools
        case budget
        case auth
    }
    var body: some Scene {
        WindowGroup {
            switch currentScreen {
            case .auth:
                AuthView(navigateTo: $currentScreen)
            case .landing:
                LandingPage(navigateTo: $currentScreen)
            case .list:
                ListView(navigateTo: $currentScreen)
            case .analytics:
                AnalyticView(navigateTo: $currentScreen, chats: $chats)
            case .tools:
                ToolView(navigateTo: $currentScreen)
            case .budget:
                BudgetView(navigateTo: $currentScreen)
            }
        }
    }
}

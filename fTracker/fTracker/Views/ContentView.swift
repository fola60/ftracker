//
//  ContentView.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 12/06/2025.
//

import SwiftUI
let someText: String = "Hello, world!"
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(someText)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//
//  LandingPage.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 01/07/2025.
//

import SwiftUI


struct LandingPage: View {
    
    var body: some View {
        
        VStack {
            HeaderView(section: HeaderView.Section.overview)
            
            ScrollView {
                // Components
            }
            Spacer()
            FooterView(section: FooterView.Section.overview)
        }
    }
}

#Preview {
    LandingPage()
}

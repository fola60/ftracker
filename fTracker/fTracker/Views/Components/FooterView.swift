//
//  Footer.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 01/07/2025.
//
// Analytics, Overview Tools
import SwiftUI


struct FooterView: View {
    enum Section {
        case analytic, overview, tool
    }
    
    @State var section: Section
    
    
    var body: some View {
        Spacer()
        HStack {
            VStack {
                Button {
                    section = .overview
                } label: {
                    Image(systemName: "eye.fill")
                        .resizable()
                        .foregroundStyle(section == Section.overview ? Globals.primaryColor : .gray)
                        .frame(width: 35, height: 25)
                    
                }
                .disabled(section == Section.overview)
                Text("Overview")
                    .font(.system(size: 12))
                    .foregroundStyle(section == Section.overview ? .black : .gray)
                
            }
            
            Spacer()
            VStack {
                Button {
                    section = .analytic
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .resizable()
                        .foregroundStyle(section == Section.analytic ? Globals.primaryColor : .gray)
                        .frame(width: 25, height: 25)
                    
                }
                .disabled(section == Section.analytic)
                Text("Analytics")
                    .font(.system(size: 12))
                    .foregroundStyle(section == Section.analytic ? .black : .gray)
            }
            Spacer()
            
            VStack {
                Button {
                    section = .tool
                } label: {
                    Image(systemName: "wrench.adjustable")
                        .resizable()
                        .foregroundStyle(section == Section.tool ? Globals.primaryColor : .gray)
                        .frame(width: 25, height: 25)
                }
                .disabled(section == Section.tool)
                Text("Tools")
                    .font(.system(size: 12))
                    .foregroundStyle(section == Section.tool ? .black : .gray)
                
            }
        }
        .padding(.leading, 26)
        .padding(.trailing,26)
        .padding(.bottom, 6)
        
    }
}

#Preview {
    FooterView(section: FooterView.Section.overview)
}

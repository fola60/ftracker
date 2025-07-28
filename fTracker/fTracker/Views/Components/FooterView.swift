//
//  Footer.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 01/07/2025.
//
// Analytics, Overview Tools
import SwiftUI


struct FooterView: View {
    @Binding var navigateTo: fTrackerApp.Screen
    enum Section {
        case analytic, overview, tool, budget
    }
    
    @State var section: Section
    
    
    var body: some View {
        Spacer()
        HStack {
            VStack {
                Button {
                    section = .overview
                    navigateTo = .landing
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
                    navigateTo = .analytics
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
                    section = .budget
                    navigateTo = .budget
                } label: {
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .foregroundStyle(section == Section.budget ? Globals.primaryColor : .gray)
                        .frame(width: 25, height: 25)
                    
                }
                .disabled(section == Section.budget)
                Text("Budget")
                    .font(.system(size: 12))
                    .foregroundStyle(section == Section.budget ? .black : .gray)
            }
            
            Spacer()
            
            VStack {
                Button {
                    section = .tool
                    navigateTo = .tools
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




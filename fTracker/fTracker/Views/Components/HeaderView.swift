//
//  Header.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 01/07/2025.
//
// Overview and List
import SwiftUI

struct HeaderView: View {
    enum Section {
        case overview, list, budget
    }
    
    @Binding var navigateTo: fTrackerApp.Screen
    @State var section: Section
    
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 25, height: 25)
                }
                Spacer()
            }
            .padding()
            
            HStack {
                Button {
                    navigateTo = .landing
                } label: {
                    Text("Overview")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
                .frame(width: 120, height: 35)
                .background(section == Section.overview ? Color.white.opacity(0.1) : Color.clear)
                .cornerRadius(20)
                

                
                Button {
                    navigateTo = .list
                } label: {
                    Text("List")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                    
                }
                .frame(width: 120, height: 35)
                .background(section == Section.list ? Color.white.opacity(0.1) : Color.clear)
                .cornerRadius(20)
                
                
            }
            
        }
        .frame(maxWidth: .infinity, minHeight: 105)
        .background(Globals.primaryColor)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
        Spacer()
    }
    
}


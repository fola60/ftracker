import SwiftUI

struct ToolView: View {
    @Binding var navigateTo: fTrackerApp.Screen
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding()
                    
                    Text("Tools")
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .font(.system(size: 32))
                    
                    Spacer()
                        .frame(width: 50)
                }
                .padding()
                Spacer()
            }
        }
    }
}

#Preview {
    @Previewable @State var navigate: fTrackerApp.Screen = .tools
    ToolView(navigateTo: $navigate)
}

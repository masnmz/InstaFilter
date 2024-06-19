//
//  ContentView.swift
//  InstaFilter
//
//  Created by Mehmet Alp Sönmez on 19/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount = 0.0
    @State private var showingConfirmation = false
    @State private var backgroundColour = Color.white
    
    
    var body: some View {
        VStack {
            Text("Hello World!")
                .blur(radius: blurAmount)
            
            Slider(value: $blurAmount, in: 0...20)
                .onChange(of: blurAmount) { oldValue, newValue in
                    print("New value is: \(newValue)")
                }
            
            Button("Random Blur") {
                blurAmount = Double.random(in: 0...20)
            }
            .padding(.bottom, 50)
            
            Button("Tap Me") {
                showingConfirmation.toggle()
            }
            .frame(width: 300, height: 300)
            .foregroundStyle(.purple)
            .background(backgroundColour)
            .confirmationDialog("Change Background", isPresented: $showingConfirmation) {
                Button("Red") { backgroundColour = .red}
                Button("Green") { backgroundColour = .green}
                Button("Blue") { backgroundColour = .blue}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select a new colour")
            }
        }

    }
}

#Preview {
    ContentView()
}

//  SplashView.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: Displays a gradient splash with fading app logo and transitions to HomeView.

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var fadeIn = false

    // MARK: - Body
    /// Shows the splash screen and transitions to the home screen after a short delay.
    var body: some View {
        Group {
            if isActive {
                HomeView()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.835, blue: 0.502), // #FFD580
                            Color(red: 0.424, green: 0.388, blue: 1.0)   // #6C63FF
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    Image("CharikawaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .opacity(fadeIn ? 1 : 0)
                        .animation(.easeIn(duration: 1.2), value: fadeIn)
                }
                .transition(.opacity)
                .onAppear {
                    fadeIn = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}


//
//  ContentView.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: Simple placeholder view used in previews; not part of primary navigation.

import SwiftUI

struct ContentView: View {
    // MARK: - Body
    /// Renders a simple placeholder interface for previews and scaffolding.
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Charikawa")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

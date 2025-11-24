//  CharikawaApp.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: App entry point configuring environment objects and launching the splash screen.

import SwiftUI
import CoreData

@main
struct CharikawaApp: App {
    // MARK: - Properties
    @StateObject private var memoryVM = MemoryViewModel()
    private let persistence = PersistenceController.shared

    // MARK: - Scene
    /// Creates the main application scene and injects shared dependencies.
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(memoryVM)
        }
    }
}

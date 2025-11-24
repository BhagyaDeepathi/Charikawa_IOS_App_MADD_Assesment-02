//  PersistenceController.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: Configures Core Data stack and provides a shared and preview controller.

import Foundation
import CoreData

struct PersistenceController {
    // MARK: - Singleton
    static let shared = PersistenceController()

    // MARK: - Properties
    let container: NSPersistentContainer

    // MARK: - Init
    /// Initializes the Core Data stack for the app.
    /// - Parameter inMemory: Uses an in-memory store for previews/tests when true.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Charikawa")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Preview
    /// A preview controller configured with an in-memory store.
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}

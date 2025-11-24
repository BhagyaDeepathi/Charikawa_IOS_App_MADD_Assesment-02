//  MemoryViewModel.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: ViewModel responsible for managing Memory entities, Core Data persistence, and ML-based image classification.

import Foundation
import CoreData
import SwiftUI
import CoreLocation
import UIKit
import Vision
import CoreML

final class MemoryViewModel: ObservableObject {
    // MARK: - Properties
    let persistence: PersistenceController
    let context: NSManagedObjectContext
    @Published var memories: [Memory] = []
    @Published var focusCoordinate: CLLocationCoordinate2D?
    @Published var currentTag: String = ""

    // MARK: - Init
    /// Initializes the ViewModel with a persistence controller.
    /// - Parameter persistence: Persistence controller (defaults to shared).
    /// - Side effects: Immediately fetches memories from Core Data.
    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
        self.context = persistence.container.viewContext
        fetchMemories()
    }

    // MARK: - Core Data (Fetch/Save/Update/Delete)
    /// Fetches memories from Core Data sorted by creation date descending.
    /// - Side effects: Updates `memories` published array.
    func fetchMemories() {
        let request = NSFetchRequest<Memory>(entityName: "Memory")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            memories = try context.fetch(request)
        } catch {
            print("Failed to fetch memories: \(error)")
        }
    }

    /// Creates and saves a new memory to Core Data.
    /// - Parameters:
    ///   - title: Optional title for the memory.
    ///   - note: Optional descriptive note.
    ///   - latitude: Latitude of the memory location.
    ///   - longitude: Longitude of the memory location.
    ///   - image: Optional image data.
    ///   - category: Optional category/tag.
    /// - Side effects: Persists a new `Memory`, updates `memories`.
    func saveMemory(title: String?, note: String?, latitude: Double, longitude: Double, image: Data?, category: String? = nil) {
        let memory = Memory(context: context)
        memory.id = UUID()
        memory.createdAt = Date()
        memory.title = title
        memory.note = note
        memory.latitude = latitude
        memory.longitude = longitude
        memory.imageData = image
        memory.category = category
        save()
        fetchMemories()
    }

    /// Updates an existing memory and persists changes.
    /// - Parameters:
    ///   - memory: Target memory to update.
    ///   - title: Updated title (optional).
    ///   - note: Updated note (optional).
    ///   - image: Updated image data (optional).
    ///   - category: Updated category (optional).
    /// - Side effects: Saves context and refreshes `memories`.
    func updateMemory(memory: Memory, title: String?, note: String?, image: Data?, category: String? = nil) {
        memory.title = title
        memory.note = note
        memory.imageData = image
        if let category = category { memory.category = category }
        save()
        fetchMemories()
    }

    /// Deletes the given memory from Core Data.
    /// - Parameter memory: The memory to delete.
    /// - Side effects: Saves context and refreshes `memories`.
    func deleteMemory(memory: Memory) {
        context.delete(memory)
        save()
        fetchMemories()
    }

    /// Saves the current Core Data context.
    /// - Side effects: Persists pending changes in the managed object context.
    func save() {
        do { try context.save() } catch { print("Save error: \(error)") }
    }

    // MARK: - ML Classification
    /// Classifies the selected memory image using CoreML and Vision.
    /// - Parameter uiImage: UIImage selected by the user.
    /// - Parameter completion: Closure returning the predicted tag string (if any).
    /// - Side effects: Prints debug logs and invokes completion on the main thread.
    func classifyImage(_ uiImage: UIImage, completion: @escaping (String?) -> Void) {
        guard let ciImage = CIImage(image: uiImage) else {
            print("❌ Failed to convert UIImage to CIImage")
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let model = try VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model)
                let request = VNCoreMLRequest(model: model) { request, error in
                    if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                        let label = topResult.identifier.capitalized
                        let confidence = topResult.confidence
                        print("✅ Detected: \(label) (\(Int(confidence * 100))%)")
                        DispatchQueue.main.async {
                            if confidence >= 0.2 {
                                completion(label)
                            } else {
                                completion(nil)
                            }
                        }
                    } else {
                        print("⚠️ No classification result.")
                        DispatchQueue.main.async { completion(nil) }
                    }
                }

                let handler = VNImageRequestHandler(ciImage: ciImage)
                try handler.perform([request])
            } catch {
                print("❌ Vision request failed: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}


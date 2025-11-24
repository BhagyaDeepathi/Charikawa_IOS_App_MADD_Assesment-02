//  AddMemoryView.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: Form for creating or editing a memory with title, note, location, photo, and optional ML tag.

import SwiftUI
import CoreLocation
import PhotosUI
import Vision
import CoreML
import UIKit

struct AddMemoryView: View {
    // MARK: - Environment / Dependencies
    @EnvironmentObject var memoryVM: MemoryViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs
    var coordinate: CLLocationCoordinate2D?
    var memory: Memory?
    // MARK: - Form State
    @State private var titleText: String = ""
    @State private var noteText: String = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showDeleteConfirm = false
    @State private var categoryText: String = ""
    // MARK: - Formatters
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    // MARK: - Body
    /// Renders the add/edit memory form with sections for details, photo, and actions.
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 1.0, green: 0.935, blue: 0.75),
                Color(red: 0.85, green: 0.82, blue: 1.0)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ScrollView {
            VStack(spacing: 16) {
                if let existing = memory, let created = existing.createdAt {
                    card {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Details").font(.custom("Poppins-Bold", size: 20)).bold()
                            Text("Added on: \(dateFormatter.string(from: created))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let coord = coordinate, memory == nil {
                    card {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location").font(.custom("Poppins-Bold", size: 18)).bold()
                            Text(String(format: "lat: %.5f, lon: %.5f", coord.latitude, coord.longitude))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details").font(.custom("Poppins-Bold", size: 20)).bold()
                        TextField("Title", text: $titleText)
                            .font(.system(size: 16, weight: .regular))
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary)
                            TextEditor(text: $noteText)
                                .font(.system(size: 16))
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }

                card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photo").font(.custom("Poppins-Bold", size: 20)).bold()
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text(imageData == nil ? "Select a photo" : "Change photo")
                                Spacer()
                            }
                            .padding(12)
                            .background(LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if let data = imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 6)
                            if !memoryVM.currentTag.isEmpty {
                                HStack(spacing: 6) {
                                    Text("Detected category:")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Text(tagWithEmoji(memoryVM.currentTag))
                                        .font(.footnote.weight(.semibold))
                                }
                            }
                            TextField("Edit tag (optional)", text: $categoryText)
                                .textInputAutocapitalization(.words)
                                .padding(10)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else if imageData == nil, let existing = memory, let data = existing.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 6)
                            if let tag = existing.category, !tag.isEmpty, memoryVM.currentTag.isEmpty {
                                HStack(spacing: 6) {
                                    Text("Detected category:")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Text(tagWithEmoji(tag))
                                        .font(.footnote.weight(.semibold))
                                }
                            }
                            TextField("Edit tag (optional)", text: $categoryText)
                                .textInputAutocapitalization(.words)
                                .padding(10)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }

                if memory != nil {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("Delete Memory")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 4)
                }
            }
            .padding(16)
            }
        }
        .navigationTitle(memory == nil ? "Add Memory" : "Edit Memory")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { saveOrUpdate() }
                    .disabled(!isValid)
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let downsized = downsampleImageData(data, maxDimension: 1400)
                    await MainActor.run { self.imageData = downsized }
                    // Run classification via ViewModel asynchronously
                    if let downsized = downsized, let ui = UIImage(data: downsized) {
                        memoryVM.classifyImage(ui) { tag in
                            if let tag = tag {
                                memoryVM.currentTag = tag
                                if self.categoryText.isEmpty { self.categoryText = tag }
                            } else {
                                memoryVM.currentTag = "Unrecognized"
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if let m = memory {
                titleText = m.title ?? ""
                noteText = m.note ?? ""
                categoryText = m.category ?? ""
                memoryVM.currentTag = m.category ?? ""
                // imageData left nil so we can show existing without copying; picker will override when selected
            }
        }
        .alert("Are you sure you want to delete this memory?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let m = memory { memoryVM.deleteMemory(memory: m) }
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Actions
    /// Saves a new memory or updates an existing one based on context.
    /// - Side effects: Writes to Core Data via `MemoryViewModel`, dismisses the view.
    private func saveOrUpdate() {
        guard isValid else { return }
        if let m = memory {
            memoryVM.updateMemory(memory: m, title: titleText, note: noteText, image: imageData ?? m.imageData, category: categoryText.isEmpty ? m.category : categoryText)
        } else if let coord = coordinate {
            memoryVM.saveMemory(
                title: titleText,
                note: noteText,
                latitude: coord.latitude,
                longitude: coord.longitude,
                image: imageData,
                category: categoryText.isEmpty ? nil : categoryText
            )
        }
        dismiss()
    }

    // MARK: - Validation
    /// Indicates whether the form has the required data to be saved.
    /// - Returns: True if title, note, and a coordinate/memory context are present.
    private var isValid: Bool {
        !titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (memory != nil || coordinate != nil)
    }

    @ViewBuilder
    // MARK: - Components
    /// Card container with background, border, and shadow.
    /// - Parameter content: View builder for card content.
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(LinearGradient(colors: [
                                Color(red: 1.0, green: 0.835, blue: 0.502).opacity(0.5),
                                Color(red: 0.424, green: 0.388, blue: 1.0).opacity(0.5)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    )
            )
    }

    // MARK: - Imaging
    /// Downsamples image data to a maximum dimension for performance and storage.
    /// - Parameters:
    ///   - data: Original image data.
    ///   - maxDimension: Maximum width/height dimension in pixels.
    /// - Returns: JPEG data for the downsized image.
    private func downsampleImageData(_ data: Data, maxDimension: CGFloat) -> Data? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimension)
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgThumb = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return data
        }
        let uiImage = UIImage(cgImage: cgThumb)
        return uiImage.jpegData(compressionQuality: 0.85)
    }

    /// Maps a detected label to an emoji-enhanced string for display.
    /// - Parameter label: The ML-provided or user tag label.
    /// - Returns: A decorated label with an appropriate emoji.
    private func tagWithEmoji(_ label: String) -> String {
        let lower = label.lowercased()
        let emoji: String
        if lower.contains("beach") || lower.contains("coast") { emoji = "🏖️" }
        else if lower.contains("mountain") { emoji = "🏔️" }
        else if lower.contains("dog") || lower.contains("cat") || lower.contains("animal") { emoji = "🐾" }
        else if lower.contains("food") || lower.contains("pizza") || lower.contains("burger") { emoji = "🍽️" }
        else if lower.contains("building") || lower.contains("architecture") || lower.contains("city") { emoji = "🏙️" }
        else if lower.contains("person") || lower.contains("human") { emoji = "🧑" }
        else { emoji = "🏷️" }
        return "\(label) \(emoji)"
    }
}

#Preview {
    NavigationStack { AddMemoryView(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), memory: nil) }
        .environmentObject(MemoryViewModel(persistence: .preview))
}

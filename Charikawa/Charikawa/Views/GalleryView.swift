//  GalleryView.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: Displays saved memories in grid or timeline views with search, share, and edit capabilities.

import SwiftUI
import UIKit
import CoreLocation

struct GalleryView: View {
    // MARK: - Properties
    @EnvironmentObject var memoryVM: MemoryViewModel
    @State private var editingMemory: Memory?
    @State private var displayMode: DisplayMode = .grid
    @State private var searchQuery: String = ""
    // Programmatic navigation flag to jump to Map when tapping "View on Map".
    @State private var goToMap: Bool = false
    // MARK: - Formatters
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    private let monthYearFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        return df
    }()

    // MARK: - Body
    /// Renders the gallery with mode picker, search, and either grid or timeline layout.
    var body: some View {
        ZStack {
            // Hidden link used to navigate to the main Map screen after setting focus coordinate.
            // We set `memoryVM.focusCoordinate` and then toggle `goToMap` to true.
            NavigationLink(isActive: $goToMap) { MapView() } label: { EmptyView() }
            LinearGradient(colors: [
                Color(red: 1.0, green: 0.96, blue: 0.85),
                Color(red: 0.90, green: 0.88, blue: 1.0)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            Group {
                if memoryVM.memories.isEmpty {
                    VStack(spacing: 12) {
                        Text("No memories yet 🌍")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Long-press on the map to add your first memory.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                } else {
                    VStack(spacing: 0) {
                        modePicker
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 4)

                        // Search bar
                        TextField("Search memories...", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .padding(.bottom, 6)

                        if displayMode == .grid {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                                    ForEach(filteredMemories, id: \.objectID) { memory in
                                        gridCard(memory)
                                            .contentShape(Rectangle())
                                            .onTapGesture { editingMemory = memory }
                                    }
                                }
                                .padding()
                                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
                            }
                        } else {
                            List {
                                ForEach(groupedMemories, id: \.0) { section in
                                    Section(header: Text(section.0).font(.headline)) {
                                        ForEach(section.1, id: \.objectID) { memory in
                                            listRow(memory)
                                                .listRowBackground(Color.clear)
                                                .contentShape(Rectangle())
                                                .onTapGesture { editingMemory = memory }
                                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                    Button(role: .destructive) {
                                                        withAnimation(.easeInOut) { memoryVM.deleteMemory(memory: memory) }
                                                    } label: { Label("Delete", systemImage: "trash") }
                                                }
                                        }
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                            .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .bottom)), removal: .opacity))
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: memoryVM.memories.count)
        .animation(.easeInOut, value: displayMode)
        .animation(.easeInOut, value: searchQuery)
        .navigationTitle("Gallery")
        .sheet(isPresented: Binding(get: { editingMemory != nil }, set: { if !$0 { editingMemory = nil } })) {
            if let mem = editingMemory {
                NavigationStack {
                    AddMemoryView(coordinate: nil, memory: mem)
                        .environmentObject(memoryVM)
                }
            }
        }
    }

    // MARK: - Controls
    /// Segmented control to switch between grid and timeline views.
    private var modePicker: some View {
        Picker("Mode", selection: $displayMode) {
            Text("Grid").tag(DisplayMode.grid)
            Text("Timeline").tag(DisplayMode.timeline)
        }
        .pickerStyle(.segmented)
        .onChange(of: displayMode) { _, _ in withAnimation(.easeInOut) {} }
    }

    // MARK: - Data
    /// Groups memories by month-year for the timeline view.
    private var groupedMemories: [(String, [Memory])] {
        let groups = Dictionary(grouping: filteredMemories) { (m: Memory) -> String in
            if let d = m.createdAt { return monthYearFormatter.string(from: d) }
            return "Unknown"
        }
        // Sort sections by date desc using a helper parse
        return groups.keys.sorted(by: { lhs, rhs in
            (monthYearFormatter.date(from: lhs) ?? .distantPast) > (monthYearFormatter.date(from: rhs) ?? .distantPast)
        }).map { key in (key, groups[key]!.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }) }
    }

    /// Filters memories by the search query against title.
    private var filteredMemories: [Memory] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return memoryVM.memories
        }
        return memoryVM.memories.filter { mem in
            (mem.title ?? "").localizedCaseInsensitiveContains(searchQuery)
        }
    }

    @ViewBuilder
    // MARK: - Components (List)
    /// Row view for a single memory in timeline mode.
    /// - Parameter memory: Memory to render.
    private func listRow(_ memory: Memory) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let data = memory.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.quaternary, lineWidth: 0.5))
            } else {
                ZStack {
                    LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "photo")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(memory.title ?? "Untitled")
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                if let note = memory.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                if let tag = memory.category, !tag.isEmpty {
                    Text(tagWithEmoji(tag))
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(categoryColor(for: tag))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                if let created = memory.createdAt {
                    Text("Added on \(dateFormatter.string(from: created))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // View on Map: sets the focus coordinate and navigates to Map.
            Button {
                memoryVM.focusCoordinate = CLLocationCoordinate2D(latitude: memory.latitude, longitude: memory.longitude)
                goToMap = true
            } label: {
                Label("View on Map", systemImage: "mappin.and.ellipse")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.borderless)

            Button {
                shareMemory(memory)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
            }
            .buttonStyle(.borderless)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }

    @ViewBuilder
    // MARK: - Components (Grid)
    /// Card view for a single memory in grid mode.
    /// - Parameter memory: Memory to render.
    private func gridCard(_ memory: Memory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let data = memory.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    shareMemory(memory)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(6)
            }

            if let tag = memory.category, !tag.isEmpty {
                Text(tagWithEmoji(tag))
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(categoryColor(for: tag))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            Text(memory.title ?? "Untitled")
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(1)
            if let note = memory.note, !note.isEmpty {
                Text(note)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            if let created = memory.createdAt {
                Text("Added on \(dateFormatter.string(from: created))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // Inline actions
            HStack(spacing: 10) {
                // View on Map button: jumps to Map and highlights this memory's pin.
                Button {
                    memoryVM.focusCoordinate = CLLocationCoordinate2D(latitude: memory.latitude, longitude: memory.longitude)
                    goToMap = true
                } label: {
                    Label("View on Map", systemImage: "mappin.and.ellipse")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Styling
    /// Maps a category tag to a background color for chips.
    private func categoryColor(for tag: String) -> Color {
        let lower = tag.lowercased()
        if lower.contains("beach") || lower.contains("coast") { return Color.blue.opacity(0.8) }
        if lower.contains("food") || lower.contains("pizza") || lower.contains("sushi") { return Color.orange.opacity(0.8) }
        if lower.contains("architecture") || lower.contains("building") || lower.contains("city") { return Color.gray.opacity(0.8) }
        if lower.contains("mountain") || lower.contains("hill") { return Color.green.opacity(0.8) }
        if lower.contains("animal") || lower.contains("dog") || lower.contains("cat") { return Color.purple.opacity(0.8) }
        if lower.contains("unrecognized") { return Color.secondary.opacity(0.5) }
        return Color.indigo.opacity(0.8)
    }

    /// Adds an emoji to the provided label for friendly display.
    private func tagWithEmoji(_ label: String) -> String {
        let lower = label.lowercased()
        if lower.contains("beach") || lower.contains("coast") { return "\(label) 🏖️" }
        if lower.contains("mountain") { return "\(label) 🏔️" }
        if lower.contains("food") || lower.contains("pizza") || lower.contains("sushi") { return "\(label) 🍣" }
        if lower.contains("architecture") || lower.contains("building") { return "\(label) 🏛️" }
        if lower.contains("animal") || lower.contains("dog") || lower.contains("cat") { return "\(label) 🐾" }
        if lower.contains("city") { return "\(label) 🏙️" }
        if lower.contains("unrecognized") { return "\(label) ❓" }
        return "\(label) 🏷️"
    }

    // MARK: - Sharing
    /// Renders a shareable image card for the memory and presents a share sheet.
    /// - Parameter memory: Memory to share.
    /// - Side effects: Presents UIActivityViewController.
    private func shareMemory(_ memory: Memory) {
        let renderer = ImageRenderer(content:
            VStack(alignment: .leading, spacing: 8) {
                if let imageData = memory.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Text(memory.title ?? "Untitled")
                    .font(.headline)
                if let note = memory.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let category = memory.category, !category.isEmpty {
                    Text(tagWithEmoji(category))
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(categoryColor(for: category))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                if let date = memory.createdAt {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )

        if let uiImage = renderer.uiImage {
            let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let root = window.rootViewController {
                root.present(activityVC, animated: true)
            }
        }
    }

    enum DisplayMode { case grid, timeline }
}

#Preview {
    NavigationStack { GalleryView() }
        .environmentObject(MemoryViewModel(persistence: .preview))
}

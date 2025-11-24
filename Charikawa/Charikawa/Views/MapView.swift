//  MapView.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: SwiftUI map screen with search, autocomplete, user location, and memory pin interactions.

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    // MARK: - Properties
    @EnvironmentObject var memoryVM: MemoryViewModel
    @StateObject private var locationManager = LocationManager()
    @StateObject private var completer = SearchCompleter()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchQuery: String = ""
    @State private var showingAddSheet = false
    @State private var pendingCoordinate: CLLocationCoordinate2D?
    @FocusState private var searchFocused: Bool
    @State private var tempCoordinate: CLLocationCoordinate2D?
    @State private var showAddConfirm = false
    @State private var showSuggestions = false
    // Coordinate to visually highlight (tint + bounce) when deep-linking to a memory from Gallery.
    @State private var highlightedCoordinate: CLLocationCoordinate2D?

    // MARK: - Body
    /// Renders the map with a persistent search bar and optional autocomplete suggestions.
    var body: some View {
        ZStack(alignment: .top) {
            MapKitRepresentable(
                region: $region,
                annotations: combinedAnnotations,
                showsUserLocation: true,
                onLongPress: { coordinate in
                    tempCoordinate = coordinate
                    showAddConfirm = true
                },
                animatedUpdates: !searchFocused,
                highlightedCoordinate: highlightedCoordinate
            )
            .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 8) {
                searchBar
                if showSuggestions, !completer.results.isEmpty {
                    suggestionsList
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 12)
        }
        .navigationTitle("Map")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: Route.gallery) {
                    Image(systemName: "photo.on.rectangle")
                }
            }
        }
        // MARK: - Lifecycle
        .onAppear {
            locationManager.requestPermission()
            if let loc = locationManager.lastLocation?.coordinate {
                withAnimation { region.center = safeCoordinate(loc) }
            }
            completer.updateRegion(region)
        }
        .onReceive(locationManager.$lastLocation) { loc in
            guard let c = loc?.coordinate else { return }
            guard !searchFocused else { return }
            withAnimation { region.center = safeCoordinate(c) }
            completer.updateRegion(region)
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                AddMemoryView(coordinate: pendingCoordinate)
                    .environmentObject(memoryVM)
            }
        }
        .onChange(of: showingAddSheet) { _, isPresented in
            if isPresented {
                searchFocused = false
            } else {
                pendingCoordinate = nil
                tempCoordinate = nil
            }
        }
        // When a specific memory is selected from Gallery, center map and briefly highlight its pin.
        .onReceive(memoryVM.$focusCoordinate) { coord in
            guard let c = coord else { return }
            withAnimation {
                region = safeRegion(center: c, span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
            }
            highlightedCoordinate = c
            DispatchQueue.main.async {
                memoryVM.focusCoordinate = nil
            }
            // Auto-clear highlight after a short delay so normal tint returns.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { highlightedCoordinate = nil }
            }
        }
        .onChange(of: searchQuery) { _, new in
            completer.updateQuery(new)
            showSuggestions = !new.isEmpty
        }
        .confirmationDialog("Add a new memory here?", isPresented: $showAddConfirm, titleVisibility: .visible) {
            Button("Add Memory", role: .none) {
                pendingCoordinate = tempCoordinate
                showingAddSheet = true
            }
            Button("Cancel", role: .cancel) {
                tempCoordinate = nil
            }
        }
    }

    private var memoryAnnotations: [MKPointAnnotation] {
        memoryVM.memories.map { memory in
            let a = MKPointAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude: memory.latitude, longitude: memory.longitude)
            a.title = memory.title ?? "Memory"
            return a
        }
    }

    private var combinedAnnotations: [MKPointAnnotation] {
        var list = memoryAnnotations
        if let temp = tempCoordinate {
            let tempAnn = MKPointAnnotation()
            tempAnn.coordinate = temp
            tempAnn.title = "Found Location"
            list.append(tempAnn)
        }
        return list
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search for a place...", text: $searchQuery, onCommit: performSearch)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .focused($searchFocused)
                .submitLabel(.search)
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                    showSuggestions = false
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var suggestionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(completer.results.prefix(6), id: \.self) { completion in
                Button {
                    selectCompletion(completion)
                } label: {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "mappin.and.ellipse").foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(completion.title).font(.subheadline).foregroundStyle(.primary)
                            if !completion.subtitle.isEmpty {
                                Text(completion.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .background(Color.clear)
                if completion != completer.results.prefix(6).last {
                    Divider()
                }
            }
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
    }

    /// Triggers a natural-language search using the current `searchQuery`.
    /// - Side effects: Updates `region`, shows a temporary pin, hides suggestions.
    private func performSearch() {
        searchLocation(query: searchQuery)
    }

    /// Resolves an autocomplete completion into a concrete place and centers the map.
    /// - Parameter completion: The selected search completion.
    /// - Side effects: Updates `region`, shows a temporary pin, hides suggestions.
    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil, let response = response, let first = response.mapItems.first else { return }
            centerOnMapItem(first, boundingRegion: response.boundingRegion)
            searchFocused = false
            showSuggestions = false
        }
    }

    /// Performs a natural-language place search.
    /// - Parameter query: Arbitrary text such as cities, landmarks, trails, waterfalls.
    /// - Side effects: Updates `region`, sets `tempCoordinate`, hides suggestions.
    private func searchLocation(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil, let response = response, !response.mapItems.isEmpty else { return }
            let first = response.mapItems[0]
            centerOnMapItem(first, boundingRegion: response.boundingRegion)
            searchFocused = false
            showSuggestions = false
        }
    }

    /// Centers the map and adjusts zoom using an item's coordinate and optional bounding region.
    /// - Parameters:
    ///   - item: The map item to center on.
    ///   - boundingRegion: Region describing search result bounds, used to derive span.
    /// - Side effects: Updates `region`, sets a temporary annotation that auto-clears.
    private func centerOnMapItem(_ item: MKMapItem, boundingRegion: MKCoordinateRegion?) {
        let coord = item.placemark.coordinate
        var targetSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        if let b = boundingRegion {
            let lat = max(0.01, min(0.5, b.span.latitudeDelta * 0.6))
            let lon = max(0.01, min(0.5, b.span.longitudeDelta * 0.6))
            targetSpan = MKCoordinateSpan(latitudeDelta: lat, longitudeDelta: lon)
        }
        withAnimation {
            region = safeRegion(center: coord, span: targetSpan)
        }
        tempCoordinate = coord
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation { tempCoordinate = nil }
        }
    }

    /// Clamps and sanitizes coordinates to valid latitude/longitude ranges.
    /// - Parameter coord: Input coordinate.
    /// - Returns: A safe coordinate within valid bounds.
    private func safeCoordinate(_ coord: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var lat = max(-90.0, min(90.0, coord.latitude))
        var lon = coord.longitude
        if !lat.isFinite { lat = 0 }
        if !lon.isFinite { lon = 0 }
        if lon < -180 { lon = -180 } else if lon > 180 { lon = 180 }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    /// Builds a safe map region from a center and span, ensuring deltas are valid.
    /// - Parameters:
    ///   - center: Region center coordinate.
    ///   - span: Desired span; will be normalized if invalid.
    /// - Returns: A sanitized `MKCoordinateRegion`.
    private func safeRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan) -> MKCoordinateRegion {
        let c = safeCoordinate(center)
        var dLat = span.latitudeDelta
        var dLon = span.longitudeDelta
        if !dLat.isFinite || dLat <= 1e-6 { dLat = 0.05 }
        if !dLon.isFinite || dLon <= 1e-6 { dLon = 0.05 }
        return MKCoordinateRegion(center: c, span: MKCoordinateSpan(latitudeDelta: dLat, longitudeDelta: dLon))
    }
}

final class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
    }

    func updateRegion(_ region: MKCoordinateRegion) {
        completer.region = region
    }

    func updateQuery(_ query: String) {
        completer.queryFragment = query
        if query.isEmpty { results = [] }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }
}

#Preview {
    NavigationStack { MapView() }
        .environmentObject(MemoryViewModel(persistence: .preview))
}

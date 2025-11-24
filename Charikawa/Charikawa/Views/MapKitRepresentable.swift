//  MapKitRepresentable.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: SwiftUI wrapper around MKMapView providing annotations, user location, and long-press handling.

import SwiftUI
import MapKit

struct MapKitRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MKPointAnnotation]
    var showsUserLocation: Bool = true
    var onLongPress: ((CLLocationCoordinate2D) -> Void)?
    var animatedUpdates: Bool = true
    // Highlighted coordinate (if any) used to emphasize a specific memory pin.
    // When provided, the matching annotation view will be temporarily animated and tinted.
    var highlightedCoordinate: CLLocationCoordinate2D? = nil

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - UIViewRepresentable
    /// Creates and configures an MKMapView instance.
    /// - Parameter context: Context providing the coordinator.
    /// - Returns: Configured MKMapView.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.isRotateEnabled = false
        mapView.pointOfInterestFilter = .excludingAll

        let gesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        gesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(gesture)

        mapView.setRegion(region, animated: false)
        return mapView
    }

    /// Updates the MKMapView when the SwiftUI state changes.
    /// - Parameters:
    ///   - uiView: The hosted MKMapView instance.
    ///   - context: Context providing the coordinator.
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if !region.center.latitude.isNaN {
            let current = uiView.region
            let latDiff = abs(current.center.latitude - region.center.latitude)
            let lonDiff = abs(current.center.longitude - region.center.longitude)
            let spanLatDiff = abs(current.span.latitudeDelta - region.span.latitudeDelta)
            let spanLonDiff = abs(current.span.longitudeDelta - region.span.longitudeDelta)
            if latDiff > 1e-6 || lonDiff > 1e-6 || spanLatDiff > 1e-6 || spanLonDiff > 1e-6 {
                uiView.setRegion(region, animated: animatedUpdates)
            }
        }
        let existing = uiView.annotations.filter { !($0 is MKUserLocation) }
        uiView.removeAnnotations(existing)
        uiView.addAnnotations(annotations)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitRepresentable
        init(_ parent: MapKitRepresentable) { self.parent = parent }

        /// Handles long-press gesture on the map to produce a coordinate.
        /// - Parameter recognizer: Gesture recognizer forwarding the touch location.
        @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            guard recognizer.state == .began, let map = recognizer.view as? MKMapView else { return }
            let point = recognizer.location(in: map)
            let coordinate = map.convert(point, toCoordinateFrom: map)
            parent.onLongPress?(coordinate)
        }

        /// Provides annotation views for map pins except the user location.
        /// - Parameters:
        ///   - mapView: The hosting MKMapView.
        ///   - annotation: Annotation to render.
        /// - Returns: Configured MKAnnotationView.
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let id = "memory-annotation"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
                view?.canShowCallout = true
                view?.glyphImage = UIImage(systemName: "heart.fill")
                // Default tint
                view?.markerTintColor = UIColor.systemPink
            } else {
                view?.annotation = annotation
            }
            // If this pin matches the highlighted coordinate, tint it differently for clarity.
            if let target = parent.highlightedCoordinate, let ann = annotation as? MKPointAnnotation {
                if coordinatesEqual(ann.coordinate, target) {
                    view?.markerTintColor = UIColor.systemRed
                }
            }
            return view
        }

        /// Fades and scales in annotation views when added for a subtle entrance animation.
        /// - Parameters:
        ///   - mapView: The hosting MKMapView.
        ///   - views: Newly added annotation views.
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            for v in views where !(v.annotation is MKUserLocation) {
                v.alpha = 0
                v.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
                    v.alpha = 1
                    v.transform = .identity
                }
                // Brief bounce animation for the highlighted pin to draw attention.
                if let target = parent.highlightedCoordinate, let coord = v.annotation?.coordinate, coordinatesEqual(coord, target) {
                    let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
                    bounce.values = [0, -10, 0, -6, 0]
                    bounce.keyTimes = [0, 0.3, 0.6, 0.8, 1]
                    bounce.duration = 0.8
                    bounce.timingFunctions = [CAMediaTimingFunction(name: .easeOut), CAMediaTimingFunction(name: .easeInEaseOut), CAMediaTimingFunction(name: .easeOut), CAMediaTimingFunction(name: .easeIn)]
                    v.layer.add(bounce, forKey: "highlight-bounce")
                }
            }
        }

        /// Compares two coordinates with a small tolerance.
        private func coordinatesEqual(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Bool {
            let lat = abs(a.latitude - b.latitude)
            let lon = abs(a.longitude - b.longitude)
            return lat < 1e-5 && lon < 1e-5
        }
    }
}


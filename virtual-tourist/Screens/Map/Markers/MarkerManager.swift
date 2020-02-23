//
//  Markers.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 8/3/19.
//  Copyright © 2019. All rights reserved.
//

import GoogleMaps

protocol MarkerManaging {    
    func addMarker(at position: CLLocationCoordinate2D)
    func select(_ marker: GMSMarker)
    func removeSelectedMarker()
    func updateMarkers()
}

final class MarkerManager: MarkerManaging {
    
    private let mapView: GMSMapView
    private var selectedMarker: GMSMarker!
    private var mapMarkers: [GMSMarker] = []
    private let markerIcon = UIImage(named: "marker")
    
    init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    func addMarker(at position: CLLocationCoordinate2D) {
        updateMarkers()
        
        let marker = GMSMarker(position: position)
        
        marker.iconView = UIImageView(image: markerIcon)
        marker.map = mapView
        
        animateMarker(marker)
        mapMarkers.append(marker)
        selectedMarker = marker
    }
    
    func select(_ marker: GMSMarker) {
        remove(marker)
        updateMarkers()
        addMarker(at: marker.position)
    }
    
    func updateMarkers() {
        var markers: [GMSMarker] = []
        
        mapMarkers.forEach { marker in
            marker.map = nil
            
            let newMarker = GMSMarker(position: marker.position)
            newMarker.icon = markerIcon
            newMarker.map = mapView
            
            markers.append(newMarker)
        }
        
        mapMarkers = markers
    }
    
    func removeSelectedMarker() {
        remove(selectedMarker)
    }
    
    private func remove(_ marker: GMSMarker) {
        marker.map = nil
        
        if let index = mapMarkers.firstIndex(where: { mk -> Bool in
            mk.position.latitude == marker.position.latitude
                && mk.position.longitude == marker.position.longitude
        }) {
            mapMarkers.remove(at: index)
        }
    }
    
    private func animateMarker(_ marker: GMSMarker) {
        let velocity = CGVector(dx: 1.0, dy: 1.0)
        let timing = UISpringTimingParameters(dampingRatio: 0.3, initialVelocity: velocity)
        let animator = UIViewPropertyAnimator(duration: 0.6, timingParameters: timing)
        animator.addAnimations { marker.iconView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) }
        animator.startAnimation()
    }
}

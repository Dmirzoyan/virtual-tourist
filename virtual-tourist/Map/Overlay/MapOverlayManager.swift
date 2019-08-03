//
//  MapOpacity.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 8/3/19.
//  Copyright © 2019. All rights reserved.
//

import GoogleMaps

protocol MapOverlayManaging {
    func updateMapOverlay(for position: GMSCameraPosition)
}

final class MapOverlayManager: MapOverlayManaging {
    
    private let mapView: GMSMapView
    private var mapOverlay: GMSCircle?
    
    init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    private struct Constants {
        static let mapOverlayOpacity: CGFloat = 0.5
        static let minOverlayZoom: Float = 7
    }
    
    func updateMapOverlay(for position: GMSCameraPosition) {
        mapOverlay?.map = nil
        
        guard position.zoom > Constants.minOverlayZoom
        else { return }
        
        mapOverlay = GMSCircle(position: position.target, radius: 2000000)
        mapOverlay?.fillColor = UIColor(
            red: 133/256,
            green: 113/256,
            blue: 217/256,
            alpha: opacity(for: position.zoom)
        )
        mapOverlay?.map = mapView
    }
    
    private func opacity(for zoom: Float) -> CGFloat {
        var opacity: CGFloat = Constants.mapOverlayOpacity
        
        if zoom <= Constants.minOverlayZoom + 1 {
            opacity = CGFloat(zoom - Constants.minOverlayZoom) / 2
        }
        
        return opacity
    }
}

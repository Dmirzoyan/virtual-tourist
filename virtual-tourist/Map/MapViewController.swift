//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapInteracting {
    func viewNewLocation(for coordinate: Coordinate)
    func viewSavedLocation(for coordinate: Coordinate)
    func loadNewImages()
    func loadSavedLocations()
}

final class MapViewController: UIViewController {

    var interactor: MapInteracting!
    var locationManager: CLLocationManager!
    var feedbackGenerator: UIImpactFeedbackGenerator!
    var popupView: PopupView!
    var popupViewAnimator: PopupViewAnimating!
    var popupPreviewHeight: CGFloat!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private var mapOverlay: GMSCircle?
    private var mapMarkers: [GMSMarker] = []
    private let markerIcon = UIImage(named: "marker")
    
    private struct Constants {
        static let mapOverlayOpacity: CGFloat = 0.5
        static let initialZoom: Float = 13
        static let minOverlayZoom: Float = 7
        static let animationDuration = 0.8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        locationManager.requestWhenInUseAuthorization()        
        popupView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        interactor.loadSavedLocations()
    }
    
    private func setupMapView() {
        setupMapStyle()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        mapView.animate(toZoom: Constants.initialZoom)
        locationManager.delegate = self
    }
    
    private func setupMapStyle() {
        guard let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "geojson")
        else {
            assertionFailure("Unable to load maps style")
            return
        }
        
        mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse
        else { return }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first
        else { return }
        
        mapView.camera = GMSCameraPosition(
            target: location.coordinate,
            zoom: Constants.initialZoom,
            bearing: 0,
            viewingAngle: 0
        )

        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        animateAddressPreviewIfNeeded()
        select(marker)
        
        interactor.viewSavedLocation(for: Coordinate(
            latitude: marker.position.latitude,
            longitude: marker.position.longitude)
        )
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        popupViewAnimator.animateTransitionIfNeeded(
            to: PopupState.closed,
            isInteractionEnabled: false,
            duration: Constants.animationDuration
        )
        animateMapPadding(height: 0)
        updateMarkers()
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        feedbackGenerator.impactOccurred()
        addMarker(at: position)
        
        interactor.viewNewLocation(for: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        mapOverlay?.map = nil
        
        guard position.zoom > Constants.minOverlayZoom
        else { return }
        
        updateMapOverlay(for: position)
    }
    
    private func updateMapOverlay(for position: GMSCameraPosition) {
        mapOverlay = GMSCircle(position: position.target, radius: 2000000)
        mapOverlay?.fillColor = UIColor(red: 133/256, green: 113/256, blue: 217/256, alpha: opacity(for: position.zoom))
        mapOverlay?.map = mapView
    }
    
    private func opacity(for zoom: Float) -> CGFloat {
        var opacity: CGFloat = Constants.mapOverlayOpacity
        
        if zoom <= Constants.minOverlayZoom + 1 {
            opacity = CGFloat(zoom - Constants.minOverlayZoom) / 2
        }
        
        return opacity
    }
    
    private func animateAddressPreviewIfNeeded() {
        if popupViewAnimator.currentState == PopupState.closed {
            popupViewAnimator.animateTransitionIfNeeded(
                to: PopupState.preview,
                isInteractionEnabled: false,
                duration: Constants.animationDuration
            )
            animateMapPadding(height: popupPreviewHeight)
        }
    }
    
    private func animateMapPadding(height: CGFloat) {
        let animator = UIViewPropertyAnimator.init(duration: Constants.animationDuration, dampingRatio: 1) {
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        }
        animator.startAnimation()
    }
    
    private func animateMarker(_ marker: GMSMarker) {
        let velocity = CGVector(dx: 1.0, dy: 1.0)
        let timing = UISpringTimingParameters(dampingRatio: 0.3, initialVelocity: velocity)
        let animator = UIViewPropertyAnimator(duration: 0.6, timingParameters: timing)
        animator.addAnimations { marker.iconView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) }
        animator.startAnimation()
    }
}

extension MapViewController {
    
    func select(_ marker: GMSMarker) {
        remove(marker)
        updateMarkers()
        addMarker(at: marker.position)
    }
    
    func addMarker(at position: CLLocationCoordinate2D) {
        updateMarkers()
        
        let marker = GMSMarker(position: position)
        
        marker.iconView = UIImageView(image: markerIcon)
        marker.map = mapView
        
        animateMarker(marker)
        mapMarkers.append(marker)
    }
    
    private func updateMarkers() {
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
    
    private func remove(_ marker: GMSMarker) {
        marker.map = nil
        
        if let index = mapMarkers.firstIndex(where: { mk -> Bool in
            mk.position.latitude == marker.position.latitude
                && mk.position.longitude == marker.position.longitude
        }) {
            mapMarkers.remove(at: index)
        }
    }
}

extension MapViewController: MapDisplaying {
    
    func display(_ viewState: PopupViewState) {
        if viewState.changes.address.isChanged { animateAddressPreviewIfNeeded() }
        popupView.set(viewState: viewState)
    }
    
    func display(_ pins: [Pin]) {
        pins.forEach { pin in
            addMarker(at: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        }
    }
    
    func displayAlert(with message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension MapViewController: PopupViewDelegate {
    
    func getNewImagesButtonPressed() {
        interactor.loadNewImages()
    }
}

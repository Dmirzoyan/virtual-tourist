//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapInteracting {}

final class MapViewController: UIViewController {

    var interactor: MapInteracting!
    var locationManager: CLLocationManager!
    var feedbackGenerator: UIImpactFeedbackGenerator!
    
    private let popupView = PopupView()
    private let popupViewHeight: CGFloat = 500
    private let popupOffset: CGFloat = 100
    private var popupViewAnimator: PopupViewAnimating!
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    
    private var mapMarkers: [GMSMarker] = []
    let markerIcon = UIImage(named: "marker")
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupPopupView()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupMapView() {
        setupMapStyle()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        locationManager.delegate = self
        mapView.delegate = self
    }
    
    private func setupMapStyle() {
        guard let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "geojson")
        else {
            assertionFailure("Unable to load maps style")
            return
        }
        
        mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
    }
    
    private func setupPopupView() {
        popupViewAnimator = PopupViewAnimator(
            hostView: view,
            popupView: popupView,
            popupViewHeight: popupViewHeight,
            initialState: .closed
        )
        popupView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        popupViewAnimator.animateTransitionIfNeeded(offset: popupOffset, duration: 0.5)
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
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        remove(marker)
        updateMarkerIcons(with: markerIcon)
        addMarker(at: marker.position)
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        feedbackGenerator.impactOccurred()
        updateMarkerIcons(with: markerIcon)
        addMarker(at: position)
        
        reverseGeocodeCoordinate(coordinate) { [weak self] success, street, city in
            guard
                let strongSelf = self,
                success == true
            else { return }
            
            strongSelf.popupView.set(street: street, city: city)
            strongSelf.popupViewAnimator.animateTransitionIfNeeded(offset: strongSelf.popupOffset, duration: 0.5)
        }
    }
    
    private func addMarker(at position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        
        marker.iconView = UIImageView(image: markerIcon)
        marker.map = mapView
        
        springAnimate(marker)
        mapMarkers.append(marker)
    }
    
    private func updateMarkerIcons(with icon: UIImage?) {
        var markers: [GMSMarker] = []
        
        mapMarkers.forEach { marker in
            marker.map = nil
            
            let newMarker = GMSMarker(position: marker.position)
            newMarker.icon = icon
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
    
    private func springAnimate(_ marker: GMSMarker) {
        let velocity = CGVector(dx: 1.0, dy: 1.0)
        let timing = UISpringTimingParameters(dampingRatio: 0.3, initialVelocity: velocity)
        let animator = UIViewPropertyAnimator(duration: 0.6, timingParameters: timing)
        animator.addAnimations { marker.iconView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) }
        animator.startAnimation()
    }
    
    private func reverseGeocodeCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        completion: @escaping (Bool, String, String) -> Void
    ) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard
                let address = response?.firstResult(),
                let street = address.thoroughfare,
                let city = address.locality,
                let country = address.country
            else {
                completion(false, "", "")
                return
            }
            
            completion(true, street, "\(city), \(country)");
        }
    }
}

extension MapViewController: MapDisplaying {}

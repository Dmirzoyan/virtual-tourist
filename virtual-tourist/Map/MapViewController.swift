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
    private let popupOffset: CGFloat = 440
    private var popupViewAnimator: PopupViewAnimating!
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    
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
            initialState: .closed,
            offset: popupOffset
        )
        popupView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        popupViewAnimator.animateTransitionIfNeeded(duration: 1)
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
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        feedbackGenerator.impactOccurred()
        
        addMarker(at: coordinate)
        
        reverseGeocodeCoordinate(coordinate) { [weak self] success, address in
            guard success == true
            else { return }
            
            self?.showAlert(message: address)
        }
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: position)
        
        marker.icon = UIImage(named: "marker")
        marker.map = mapView
    }
    
    private func reverseGeocodeCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        completion: @escaping (Bool, String) -> Void
    ) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                completion(false, "")
                return
            }
            
            completion(true, lines.joined(separator: "\n"))
        }
    }
    
    private func showAlert(message: String) {
        let controller = UIAlertController(title: "Address", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}

extension MapViewController: MapDisplaying {}

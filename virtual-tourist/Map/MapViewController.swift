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
    func imageDeleted(at index: Int)
    func pinDeleted()
}

final class MapViewController: UIViewController {

    var interactor: MapInteracting!
    var locationManager: CLLocationManager!
    var feedbackGenerator: UIImpactFeedbackGenerator!
    var popupView: PopupView!
    var popupViewAnimator: PopupViewAnimating!
    var popupPreviewHeight: CGFloat!
    var deletePinButton: RoundButton!
    var deletePinButtonBottomConstraint: NSLayoutConstraint!
    var markerManager: MarkerManaging!
    var mapOverlayManager: MapOverlayManaging!
    var animationCoordinator: AnimationCoordinating!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private struct Constants {
        static let initialZoom: Float = 13
        static let deletePinButtonWidth: CGFloat = 56
        static let deletePinButtonBottomPadding: CGFloat = 80
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupDeletePinButton()
        markerManager = MarkerManager(mapView: mapView)
        mapOverlayManager = MapOverlayManager(mapView: mapView)
        
        locationManager.requestWhenInUseAuthorization()
        popupView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animationCoordinator = AnimationCoordinator(
            parentView: view,
            mapView: mapView,
            deletePinButton: deletePinButton,
            popupPreviewHeight: popupPreviewHeight,
            popupViewAnimator: popupViewAnimator,
            deletePinButtonBottomConstraint: deletePinButtonBottomConstraint
        )
        interactor.loadSavedLocations()
    }
    
    private func setupDeletePinButton() {
        deletePinButton = RoundButton()
        deletePinButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deletePinButton)
        
        deletePinButtonBottomConstraint = deletePinButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Constants.deletePinButtonBottomPadding
        )
        
        NSLayoutConstraint.activate([
            deletePinButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            deletePinButtonBottomConstraint
        ])
        
        deletePinButton.width = Constants.deletePinButtonWidth
        deletePinButton.isEnabled = false
        deletePinButton.setImage(UIImage(named: "close"), for: .normal)
        deletePinButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        deletePinButton.delegate = self
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
        markerManager.select(marker)
        
        interactor.viewSavedLocation(for: Coordinate(
            latitude: marker.position.latitude,
            longitude: marker.position.longitude)
        )
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if popupViewAnimator.currentState == .preview || popupViewAnimator.currentState == .open {
            animationCoordinator.animateViewChange(to: PopupState.closed)
            markerManager.updateMarkers()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        feedbackGenerator.impactOccurred()
        markerManager.addMarker(at: position)
        interactor.viewNewLocation(for: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        mapOverlayManager.updateMapOverlay(for: position)
    }
    
    private func animateAddressPreviewIfNeeded() {
        if popupViewAnimator.currentState == PopupState.closed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let strongSelf = self
                else { return }
                
                strongSelf.animationCoordinator.animateViewChange(to: PopupState.preview)
            }
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
            markerManager.addMarker(at: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
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
    
    func imageDeleted(at index: Int) {
        interactor.imageDeleted(at: index)
    }
}

extension MapViewController: ButtonDelegate {
    
    func isPressed() {
        if popupViewAnimator.currentState == .preview {
            markerManager.removeSelectedMarker()
            animationCoordinator.animateViewChange(to: PopupState.closed)
            interactor.pinDeleted()
        }
    }
}

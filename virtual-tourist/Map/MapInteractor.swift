//
//  MapInteractor.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
//

import GoogleMaps

protocol MapPresenting {
    func preview(_ address: Address)
    func present(_ photos: [FlickrPhoto])
    func presentAlert(with message: String)
    func presentLoadingProgress()
}

final class MapInteractor: MapInteracting {
    
    private let router: MapInternalRoute
    private let presenter: MapPresenting
    private let geocoder: GMSGeocoder
    
    init(
        router: MapInternalRoute,
        presenter: MapPresenting,
        geocoder: GMSGeocoder
    ) {
        self.router = router
        self.presenter = presenter
        self.geocoder = geocoder
    }
    
    func previewLocation(for coordinate: CLLocationCoordinate2D) {
        reverseGeocodeCoordinate(coordinate) { [weak self] success, street, city in
            guard success == true
            else { return }

            self?.presenter.preview(Address(city: city, street: street))
        }
        loadImages(for: coordinate)
    }
    
    func loadImages(for coordinate: CLLocationCoordinate2D) {
        FlickrApiClient().getImages(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) { [weak self] photos, error in
            guard
                let photos = photos,
                error == nil
                else {
                    self?.presenter.presentAlert(with: "Could not retrieve images")
                    return
            }
            self?.presenter.present(photos)
        }
        
        presenter.presentLoadingProgress()
    }
    
    private func reverseGeocodeCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        completion: @escaping (Bool, String, String) -> Void
    ) {
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

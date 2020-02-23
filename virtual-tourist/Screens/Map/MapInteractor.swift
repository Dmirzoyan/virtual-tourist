//
//  MapInteractor.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
//

import Foundation

//sourcery: mock
protocol MapPresenting {
    func preview(address: Address)
    func present(photos: [Photo])
    func present(pins: [Pin])
    func presentAlert(with message: String)
    func presentLoadingProgress()
}

final class MapInteractor: MapInteracting {
    
    private let router: MapInternalRoute
    private let presenter: MapPresenting
    private let imagesApiClient: FlickrApiAccessing
    private let geocoder: Geocoding
    private let locationPersistenceManager: LocationPersistenceManaging
    
    private var currentLocation = Location(
        address: Address(city: "", street: ""),
        photos: [],
        coordinate: Coordinate(latitude: 0, longitude: 0)
    )
    
    init(
        router: MapInternalRoute,
        presenter: MapPresenting,
        imagesApiClient: FlickrApiAccessing,
        geocoder: Geocoding,
        locationPersistenceManager: LocationPersistenceManaging
    ) {
        self.router = router
        self.presenter = presenter
        self.imagesApiClient = imagesApiClient
        self.geocoder = geocoder
        self.locationPersistenceManager = locationPersistenceManager
    }
    
    func loadSavedLocations() {
        locationPersistenceManager.load { [weak self] pins, locationToDisplay in
            guard let locationToDisplay = locationToDisplay
            else {
                self?.presenter.presentAlert(with: "Failed loading saved locations!")
                return
            }
            
            self?.presenter.present(pins: pins)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.presenter.preview(address: locationToDisplay.address)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.presenter.present(photos: locationToDisplay.photos)
                }
            }
            
            self?.currentLocation.address = locationToDisplay.address
            self?.currentLocation.coordinate = locationToDisplay.coordinate
        }
    }
    
    func viewSavedLocation(for coordinate: Coordinate) {
        locationPersistenceManager.getLocation(for: coordinate) { [weak self] location in
            guard let location = location
            else { return }
            
            self?.presenter.preview(address: location.address)
            self?.presenter.present(photos: location.photos)
            
            self?.currentLocation.address = location.address
            self?.currentLocation.coordinate = location.coordinate
        }
    }
    
    func viewNewLocation(for coordinate: Coordinate) {
        geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] success, address in
            guard
                success == true,
                let address = address
            else { return }
            
            self?.currentLocation.address = address
            self?.presenter.preview(address: address)
        }
        
        loadImages(for: coordinate) { [weak self] photos in
            guard let strongSelf = self
            else { return }
            
            strongSelf.locationPersistenceManager.save(
                Location(address: strongSelf.currentLocation.address, photos: photos, coordinate: coordinate)
            )
        }
        
        currentLocation.coordinate = coordinate
    }
    
    func loadNewImages() {
        loadImages(for: currentLocation.coordinate) { [weak self] photos in
            guard let strongSelf = self
            else { return }
            
            strongSelf.locationPersistenceManager.update(photos, for: strongSelf.currentLocation.coordinate)
        }
    }
    
    func imageDeleted(at index: Int) {
        locationPersistenceManager.deletePhoto(for: currentLocation.coordinate, at: index)
    }
    
    func pinDeleted() {
        locationPersistenceManager.deletePin(for: currentLocation.coordinate)
    }
    
    private func loadImages(for coordinate: Coordinate, completion: @escaping ([Photo]) -> Void) {
        imagesApiClient.getImages(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) { [weak self] flickrPhotos, error in
            guard
                error == nil,
                let strongSelf = self,
                let flickrPhotos = flickrPhotos
            else {
                    self?.presenter.presentAlert(with: "Could not retrieve images")
                    return
            }
            
            let photos = strongSelf.locationPersistenceManager.transform(flickrPhotos: flickrPhotos)
            strongSelf.presenter.present(photos: photos)
            
            completion(photos)
        }
        
        presenter.presentLoadingProgress()
    }
}

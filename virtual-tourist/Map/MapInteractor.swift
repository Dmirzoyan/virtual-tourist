//
//  MapInteractor.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
//

import GoogleMaps
import CoreData

protocol MapPresenting {
    func preview(_ address: Address)
    func present(_ photos: [Photo])
    func present(_ pins: [Pin])
    func presentAlert(with message: String)
    func presentLoadingProgress()
}

final class MapInteractor: MapInteracting {
    
    private let router: MapInternalRoute
    private let presenter: MapPresenting
    private let geocoder: GMSGeocoder
    private let dataController: DataController
    
    private var pinToAdd: Pin?
    private var fetchedResultsController: NSFetchedResultsController<Pin>!
    private var currentCoordinate: CLLocationCoordinate2D?
    
    init(
        router: MapInternalRoute,
        presenter: MapPresenting,
        geocoder: GMSGeocoder,
        dataController: DataController
    ) {
        self.router = router
        self.presenter = presenter
        self.geocoder = geocoder
        self.dataController = dataController
    }
    
    func loadSavedLocations() {
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "addedDate", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil,
            cacheName: "pins"
        )
        
        do {
            try fetchedResultsController.performFetch()
            
            guard
                let pins = fetchedResultsController.fetchedObjects,
                let photos = pins.last?.photos as? Set<Photo>,
                let city = pins.last?.city,
                let street = pins.last?.street
            else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard
                    let strongSelf = self
                else { return }
                
                strongSelf.presenter.preview(Address(city: city, street: street))
                strongSelf.presenter.present(strongSelf.ordered(photos))
            }
            
            presenter.present(pins)
            
        } catch {
            presenter.presentAlert(with: "Failed loading saved locations!")
        }
    }
    
    func viewNewLocation(for coordinate: CLLocationCoordinate2D) {
        reverseGeocodeCoordinate(coordinate) { [weak self] success, street, city in
            guard
                success == true,
                let strongSelf = self
            else { return }

            strongSelf.pinToAdd = Pin(context: strongSelf.dataController.viewContext)
            strongSelf.pinToAdd?.city = city
            strongSelf.pinToAdd?.street = street
            strongSelf.pinToAdd?.latitude = coordinate.latitude
            strongSelf.pinToAdd?.longitude = coordinate.longitude
            
            strongSelf.presenter.preview(Address(city: city, street: street))
        }
        loadImages(for: coordinate)
        currentCoordinate = coordinate
    }
    
    func viewSavedLocation(for coordinate: CLLocationCoordinate2D) {
        guard
            let pin = fetchedResultsController.fetchedObjects?.first(
                where: { $0.latitude == coordinate.latitude && $0.longitude == coordinate.longitude }
            ),
            let photos = pin.photos as? Set<Photo>
        else { return }
        
        presenter.present(ordered(photos))
    }
    
    func loadNewImages() {
        guard let coordinate = currentCoordinate
        else { return }
        
        loadImages(for: coordinate)
    }
    
    private func loadImages(for coordinate: CLLocationCoordinate2D) {
        FlickrApiClient().getImages(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) { [weak self] flickrPhotos, error in
            guard
                let flickrPhotos = flickrPhotos,
                error == nil,
                let strongSelf = self
            else {
                self?.presenter.presentAlert(with: "Could not retrieve images")
                return
            }
            
            let photos = strongSelf.transform(flickrPhotos)
            strongSelf.saveLocation(photos: photos)
            strongSelf.presenter.present(photos)
        }
        
        presenter.presentLoadingProgress()
    }
    
    private func transform(_ flickrPhotos: [FlickrPhoto]) -> [Photo] {
        var photos: [Photo] = []
        
        for (index, flickrPhoto) in flickrPhotos.enumerated() {
            let photo = Photo(context: dataController.viewContext)
            
            photo.title = flickrPhoto.title
            photo.url = flickrPhoto.imageUrl()?.absoluteString
            photo.thumbnailData = flickrPhoto.thumbnail?.pngData()
            photo.pin = pinToAdd
            photo.index = Int16(index)
            
            photos.append(photo)
        }
        
        return photos
    }
    
    private func saveLocation(photos: [Photo]) {
        try? dataController.viewContext.save()
    }
    
    private func ordered(_ photos: Set<Photo>) -> [Photo] {
        return photos.sorted(by: { (p1, p2) -> Bool in p1.index < p2.index })
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

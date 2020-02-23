//
//  LocationPersistenceManager.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/31/19.
//  Copyright © 2019. All rights reserved.
//

import Foundation
import CoreData

//sourcery: mock
protocol LocationPersistenceManaging {
    func load(completion: @escaping ([Pin], Location?) -> Void)
    func getLocation(for coordinate: Coordinate, completion: @escaping (Location?) -> Void)
    func save(_ location: Location)
    func update(_ photos: [Photo], for coordiate: Coordinate)
    func transform(flickrPhotos: [FlickrPhoto]) -> [Photo]
    func deletePhoto(for coordinate: Coordinate, at index: Int)
    func deletePin(for coordinate: Coordinate)
}

final class LocationPersistenceManager: LocationPersistenceManaging {
    
    private var pins: [Pin] = []
    private let dataController: DataController
    private var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    func load(completion: @escaping ([Pin], Location?) -> Void) {
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
                let street = pins.last?.street,
                let latitude = pins.last?.latitude,
                let longitude = pins.last?.longitude
            else { return }
            
            completion(pins, Location(
                address: Address(city: city, street: street),
                photos: ordered(photos),
                coordinate: Coordinate(latitude: latitude, longitude: longitude)
                )
            )
            
            self.pins = pins
            
        } catch {
            completion([], nil)
        }
    }
    
    func getLocation(for coordinate: Coordinate, completion: @escaping (Location?) -> Void) {
        guard
            let pin = pin(with: coordinate.latitude, longitude: coordinate.longitude),
            let city = pin.city,
            let street = pin.street,
            let photos = pin.photos as? Set<Photo>
        else {
            completion(nil)
            return
        }
        
        completion(Location(
            address: Address(city: city, street: street),
            photos: ordered(photos), coordinate: coordinate)
        )
    }
    
    func save(_ location: Location) {
        let pin = Pin(context: dataController.viewContext)
        pin.city = location.address.city
        pin.street = location.address.street
        pin.latitude = location.coordinate.latitude
        pin.longitude = location.coordinate.longitude
        pin.photos = NSSet.init(array: location.photos)
        
        try? dataController.viewContext.save()
        
        pins.append(pin)
    }
    
    func update(_ photos: [Photo], for coordinate: Coordinate) {
        guard let pin = pin(with: coordinate.latitude, longitude: coordinate.longitude)
        else { return }
        
        pin.photos = NSSet.init(array: photos)
        
        try? dataController.viewContext.save()
    }
    
    func transform(flickrPhotos: [FlickrPhoto]) -> [Photo] {
        var photos: [Photo] = []
        
        for (index, flickrPhoto) in flickrPhotos.enumerated() {
            let photo = Photo(context: dataController.viewContext)
            
            photo.title = flickrPhoto.title
            photo.url = flickrPhoto.imageUrl()?.absoluteString
            photo.thumbnailData = flickrPhoto.thumbnail?.pngData()
            photo.index = Int16(index)
            
            photos.append(photo)
        }
        
        return photos
    }
    
    func deletePhoto(for coordinate: Coordinate, at index: Int) {
        guard
            let pin = pin(with: coordinate.latitude, longitude: coordinate.longitude),
            let photos = pin.photos as? Set<Photo>
        else { return }
        
        dataController.viewContext.delete(ordered(photos)[index])
        try? dataController.viewContext.save()
    }
    
    func deletePin(for coordinate: Coordinate) {
        guard let pin = pin(with: coordinate.latitude, longitude: coordinate.longitude)
        else { return }
        
        dataController.viewContext.delete(pin)
        try? dataController.viewContext.save()
    }
    
    private func ordered(_ photos: Set<Photo>) -> [Photo] {
        return photos.sorted(by: { (p1, p2) -> Bool in p1.index < p2.index })
    }
    
    private func pin(with latitude: Double, longitude: Double) -> Pin? {
        return pins.first(where: { $0.latitude == latitude && $0.longitude == longitude })
    }
}

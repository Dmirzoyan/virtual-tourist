// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

@testable import virtual_tourist
import Foundation
import UIKit

class FlickrApiAccessingMock: FlickrApiAccessing {

    struct Captures {
        var getImagesLatitudeLongitudeCompletion = [GetImagesLatitudeLongitudeCompletion]()

        struct GetImagesLatitudeLongitudeCompletion {
            let latitude: Double
            let longitude: Double
            let completion: SearchPhotosCompletion
        }
    }

    struct Stubs {
    }

    var captures = Captures()
    var stubs = Stubs()

    func getImages(latitude: Double, longitude: Double, completion: @escaping SearchPhotosCompletion) {
        captures.getImagesLatitudeLongitudeCompletion.append(Captures.GetImagesLatitudeLongitudeCompletion(latitude: latitude, longitude: longitude, completion: completion))
    }
}

class GeocodingMock: Geocoding {

    struct Captures {
        var reverseGeocodeCoordinateCompletion = [ReverseGeocodeCoordinateCompletion]()

        struct ReverseGeocodeCoordinateCompletion {
            let coordinate: Coordinate
            let completion: (Bool, Address?) -> Void
        }
    }

    struct Stubs {
    }

    var captures = Captures()
    var stubs = Stubs()

    func reverseGeocodeCoordinate(        _ coordinate: Coordinate,        completion: @escaping (Bool, Address?) -> Void    ) {
        captures.reverseGeocodeCoordinateCompletion.append(Captures.ReverseGeocodeCoordinateCompletion(coordinate: coordinate, completion: completion))
    }
}

class LocationPersistenceManagingMock: LocationPersistenceManaging {

    struct Captures {
        var loadCompletion = [LoadCompletion]()
        var getLocationForCompletion = [GetLocationForCompletion]()
        var save = [Save]()
        var updateFor = [UpdateFor]()
        var transformFlickrPhotos = [TransformFlickrPhotos]()
        var deletePhotoForAt = [DeletePhotoForAt]()
        var deletePinFor = [DeletePinFor]()

        struct LoadCompletion {
            let completion: ([Pin], Location?) -> Void
        }

        struct GetLocationForCompletion {
            let coordinate: Coordinate
            let completion: (Location?) -> Void
        }

        struct Save {
            let location: Location
        }

        struct UpdateFor {
            let photos: [Photo]
            let coordiate: Coordinate
        }

        struct TransformFlickrPhotos {
            let flickrPhotos: [FlickrPhoto]
        }

        struct DeletePhotoForAt {
            let coordinate: Coordinate
            let index: Int
        }

        struct DeletePinFor {
            let coordinate: Coordinate
        }
    }

    struct Stubs {
        lazy var transformFlickrPhotos: [Photo]! = []
    }

    var captures = Captures()
    var stubs = Stubs()

    func load(completion: @escaping ([Pin], Location?) -> Void) {
        captures.loadCompletion.append(Captures.LoadCompletion(completion: completion))
    }

    func getLocation(for coordinate: Coordinate, completion: @escaping (Location?) -> Void) {
        captures.getLocationForCompletion.append(Captures.GetLocationForCompletion(coordinate: coordinate, completion: completion))
    }

    func save(_ location: Location) {
        captures.save.append(Captures.Save(location: location))
    }

    func update(_ photos: [Photo], for coordiate: Coordinate) {
        captures.updateFor.append(Captures.UpdateFor(photos: photos, coordiate: coordiate))
    }

    func transform(flickrPhotos: [FlickrPhoto]) -> [Photo] {
        captures.transformFlickrPhotos.append(Captures.TransformFlickrPhotos(flickrPhotos: flickrPhotos))
        return stubs.transformFlickrPhotos
    }

    func deletePhoto(for coordinate: Coordinate, at index: Int) {
        captures.deletePhotoForAt.append(Captures.DeletePhotoForAt(coordinate: coordinate, index: index))
    }

    func deletePin(for coordinate: Coordinate) {
        captures.deletePinFor.append(Captures.DeletePinFor(coordinate: coordinate))
    }
}

class MapInternalRouteMock: MapInternalRoute {

    struct Captures {
    }

    struct Stubs {
    }

    var captures = Captures()
    var stubs = Stubs()
}

class MapPresentingMock: MapPresenting {

    struct Captures {
        var previewAddress = [PreviewAddress]()
        var presentPhotos = [PresentPhotos]()
        var presentPins = [PresentPins]()
        var presentAlertWith = [PresentAlertWith]()
        var presentLoadingProgress = [PresentLoadingProgress]()

        struct PreviewAddress {
            let address: Address
        }

        struct PresentPhotos {
            let photos: [Photo]
        }

        struct PresentPins {
            let pins: [Pin]
        }

        struct PresentAlertWith {
            let message: String
        }

        struct PresentLoadingProgress {}
    }

    struct Stubs {
    }

    var captures = Captures()
    var stubs = Stubs()

    func preview(address: Address) {
        captures.previewAddress.append(Captures.PreviewAddress(address: address))
    }

    func present(photos: [Photo]) {
        captures.presentPhotos.append(Captures.PresentPhotos(photos: photos))
    }

    func present(pins: [Pin]) {
        captures.presentPins.append(Captures.PresentPins(pins: pins))
    }

    func presentAlert(with message: String) {
        captures.presentAlertWith.append(Captures.PresentAlertWith(message: message))
    }

    func presentLoadingProgress() {
        captures.presentLoadingProgress.append(Captures.PresentLoadingProgress())
    }
}

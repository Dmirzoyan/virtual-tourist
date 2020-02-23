//
//  MapInteractorSpec.swift
//  virtual-touristTests
//
//  Created by Davit Mirzoyan on 2/22/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Quick
import Nimble

@testable import virtual_tourist

final class RestaurantsInteractorSpec: QuickSpec {

    override func spec() {

        describe("\(MapInteractor.self)") {

            var sut: MapInteractor!
            var router: MapInternalRouteMock!
            var presenter: MapPresentingMock!
            var imagesApiClient: FlickrApiAccessingMock!
            var geocoder: GeocodingMock!
            var locationPersistenceManager: LocationPersistenceManagingMock!

            beforeEach {
                router = MapInternalRouteMock()
                presenter = MapPresentingMock()
                imagesApiClient = FlickrApiAccessingMock()
                geocoder = GeocodingMock()
                locationPersistenceManager = LocationPersistenceManagingMock()

                sut = MapInteractor(
                    router: router,
                    presenter: presenter,
                    imagesApiClient: imagesApiClient,
                    geocoder: geocoder,
                    locationPersistenceManager: locationPersistenceManager
                )
            }

            afterEach {
                sut = nil
                router = nil
                presenter = nil
                geocoder = nil
                locationPersistenceManager = nil
            }

            context("When loadNewImages is called") {
                
                beforeEach {
                    sut.loadNewImages()
                }

                it("An API call is made") {
                    expect(imagesApiClient.captures.getImagesLatitudeLongitudeCompletion.count).to(equal(1))
                }
                
                context("When callback is executed") {
                    
                    beforeEach {
                        let capture = imagesApiClient.captures.getImagesLatitudeLongitudeCompletion
                        if let completion = capture.last?.completion {
                            completion([], nil)
                        }
                    }
                    
                    it("API Images are transformed") {
                        expect(locationPersistenceManager.captures.transformFlickrPhotos.count).to(equal(1))
                    }
                    
                    it("Images are presented") {
                        expect(presenter.captures.presentPhotos.count).to(equal(1))
                    }
                    
                    it("Images are updated in the store") {
                        expect(locationPersistenceManager.captures.updateFor.count).to(equal(1))
                    }
                }
            }
            
            context("When loadSavedLocations is called") {
                
                beforeEach {
                    sut.loadSavedLocations()
                }
                
                it("Locations are loaded from persistence") {
                    expect(locationPersistenceManager.captures.loadCompletion.count).to(equal(1))
                }
                
                context("When callback is executed with no location to display") {
                    
                    beforeEach {
                        let capture = locationPersistenceManager.captures.loadCompletion
                        if let completion = capture.last?.completion {
                            completion( [], nil)
                        }
                    }
                    
                    it("Alert is presented") {
                        expect(presenter.captures.presentAlertWith.count).to(equal(1))
                    }
                }
                
                context("When callback is executed with a location to display") {

                    beforeEach {
                        let capture = locationPersistenceManager.captures.loadCompletion
                        if let completion = capture.last?.completion {
                            completion(
                                [],
                                Location(
                                    address: Address(city: "city", street: "street"),
                                    photos: [],
                                    coordinate: Coordinate(latitude: 0, longitude: 0)
                                )
                            )
                        }
                    }

                    it("Pins are presented") {
                        expect(presenter.captures.presentPins.count).to(equal(1))
                    }
                }
            }
            
            context("When viewNewLocation is called") {
                let coordinate = Coordinate(latitude: 2, longitude: 3)
                
                beforeEach {
                    sut.viewNewLocation(for: coordinate)
                }
                
                it("Reverse geocoder is invoked") {
                    let capture = geocoder.captures.reverseGeocodeCoordinateCompletion
                    
                    expect(capture.count).to(equal(1))
                    expect(capture.last?.coordinate).to(equal(coordinate))
                }
                
                context("When callback is executed") {
                    let address = Address(city: "city", street: "street")

                    beforeEach {
                        let capture = geocoder.captures.reverseGeocodeCoordinateCompletion
                        if let completion = capture.last?.completion {
                            completion(true, address)
                        }
                    }

                    it("Pins are presented") {
                        expect(presenter.captures.previewAddress.count).to(equal(1))
                        expect(presenter.captures.previewAddress.last?.address).to(equal(address))
                    }
                }
                
                it("An API call is made") {
                    expect(imagesApiClient.captures.getImagesLatitudeLongitudeCompletion.count).to(equal(1))
                }
                
                context("When callback is executed") {
                    
                    beforeEach {
                        let capture = imagesApiClient.captures.getImagesLatitudeLongitudeCompletion
                        if let completion = capture.last?.completion {
                            completion([], nil)
                        }
                    }
                    
                    it("Images are saved") {
                        expect(locationPersistenceManager.captures.save.count).to(equal(1))
                    }
                }
            }
        }
    }
}


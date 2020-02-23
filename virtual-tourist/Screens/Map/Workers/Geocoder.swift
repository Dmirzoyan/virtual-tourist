//
//  Geocoder.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 8/2/19.
//  Copyright © 2019. All rights reserved.
//

import GoogleMaps

//sourcery: mock
protocol Geocoding {
    func reverseGeocodeCoordinate(
        _ coordinate: Coordinate,
        completion: @escaping (Bool, Address?) -> Void
    )
}

final class Geocoder: Geocoding {
    
    private let geocoder: GMSGeocoder
    
    init(geocoder: GMSGeocoder) {
        self.geocoder = geocoder
    }
    
    func reverseGeocodeCoordinate(
        _ coordinate: Coordinate,
        completion: @escaping (Bool, Address?) -> Void
    ) {
        geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )) { response, error in
            guard
                let address = response?.firstResult(),
                let street = address.thoroughfare,
                let city = address.locality,
                let country = address.country
            else {
                completion(false, nil)
                return
            }
            
            completion(true, Address(city: "\(city), \(country)", street: street));
        }
    }
}

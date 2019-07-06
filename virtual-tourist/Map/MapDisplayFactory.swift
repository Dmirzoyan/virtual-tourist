//
//  MapDisplayFactory.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MapDisplayProducing {
    func make(router: MapInternalRoute) -> UIViewController
}

final class MapDisplayFactory: MapDisplayProducing {
    
    func make(router: MapInternalRoute) -> UIViewController {
        let viewController = MapViewController()
        let presenter = MapPresenter(display: viewController)
        
        let interactor = MapInteractor(
            router: router,
            presenter: presenter
        )
        
        viewController.interactor = interactor
        viewController.locationManager = CLLocationManager()
        
        return viewController
    }
}

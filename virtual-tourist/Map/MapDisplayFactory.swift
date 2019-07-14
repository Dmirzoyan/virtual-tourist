//
//  MapDisplayFactory.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
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
            presenter: presenter,
            geocoder: GMSGeocoder()
        )
        
        viewController.interactor = interactor
        viewController.locationManager = CLLocationManager()
        viewController.feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        
        let popupView = PopupView()
        
        viewController.popupView = popupView
        viewController.popupViewAnimator = PopupViewAnimator(
            hostView: viewController.view,
            popupView: popupView,
            popupViewHeight: 500,
            popupPreviewHeight: 100,
            initialState: .closed
        )
        
        return viewController
    }
}

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
    let popupViewHeight: CGFloat = 500
    let popupPreviewHeight: CGFloat = 100
    
    func make(router: MapInternalRoute) -> UIViewController {
        let viewController = MapViewController()
        let presenter = MapPresenter(display: viewController)
        
        let interactor = MapInteractor(
            router: router,
            presenter: presenter,
            geocoder: GMSGeocoder(),
            dataController: Dependencies.dataController
        )
        
        viewController.interactor = interactor
        viewController.locationManager = CLLocationManager()
        viewController.feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        
        let popupView = PopupView()
        
        viewController.popupView = popupView
        layout(popupView, on: viewController.view)
        
        let bottomConstraint = popupView.bottomAnchor.constraint(
            equalTo: viewController.view.bottomAnchor,
            constant: popupViewHeight
        )
        bottomConstraint.isActive = true
        
        viewController.popupViewAnimator = PopupViewAnimator(
            hostView: viewController.view,
            popupView: popupView,
            popupViewHeight: popupViewHeight,
            popupPreviewHeight: popupPreviewHeight,
            initialState: .closed,
            bottomConstraint: bottomConstraint
        )
        
        viewController.popupPreviewHeight = popupPreviewHeight
        
        return viewController
    }
    
    private func layout(_ popupView: UIView, on hostView: UIView) {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(popupView)
        
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: hostView.leadingAnchor, constant: PopupView.borderMargin),
            popupView.trailingAnchor.constraint(equalTo: hostView.trailingAnchor, constant: -PopupView.borderMargin),
            popupView.heightAnchor.constraint(equalToConstant: popupViewHeight),
        ])
    }
}

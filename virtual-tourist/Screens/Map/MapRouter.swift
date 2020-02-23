//
//  MapRouter.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol MapRoute {
    func start()
}

//sourcery: mock
protocol MapInternalRoute {}

final class MapRouter: MapRoute {
    
    private let navigationController: UINavigationController
    private let displayFactory: MapDisplayProducing
    
    init(
        navigationController: UINavigationController,
        displayFactory: MapDisplayProducing
    ) {
        self.navigationController = navigationController
        self.displayFactory =  displayFactory
    }
    
    func start() {
        let viewController = displayFactory.make(router: self)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension MapRouter: MapInternalRoute {}

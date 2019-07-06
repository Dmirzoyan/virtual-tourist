//
//  MapRouterFactory.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

protocol MapRouterProducing {
    func make() -> MapRoute
}

final class MapRouterFactory: MapRouterProducing {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func make() -> MapRoute {
        return MapRouter(
            navigationController: navigationController,
            displayFactory: MapDisplayFactory()
        )
    }
}

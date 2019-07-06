//
//  MapInteractor.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

protocol MapPresenting {}

final class MapInteractor: MapInteracting {
    
    private let router: MapInternalRoute
    private let presenter: MapPresenting
    
    init(
        router: MapInternalRoute,
        presenter: MapPresenting
    ) {
        self.router = router
        self.presenter = presenter
    }
}

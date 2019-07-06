//
//  MapPresenter.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

protocol MapDisplaying {}

final class MapPresenter: MapPresenting {
    
    private let display: MapDisplaying
    
    init(display: MapDisplaying) {
        self.display = display
    }
}

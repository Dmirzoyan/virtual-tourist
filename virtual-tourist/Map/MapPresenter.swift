//
//  MapPresenter.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol MapDisplaying {
    func preview(_ address: Address)
}

final class MapPresenter: MapPresenting {
    
    private var display: MapDisplaying?
    
    init(display: MapDisplaying) {
        self.display = display
    }
    
    func preview(_ address: Address) {
        display?.preview(address)        
    }
}

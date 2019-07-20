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
    func display(_ photos: [FlickrPhoto])
    func displayAlert(with message: String)
}

final class MapPresenter: MapPresenting {
    
    private var display: MapDisplaying?
    
    init(display: MapDisplaying) {
        self.display = display
    }
    
    func preview(_ address: Address) {
        display?.preview(address)        
    }
    
    func presentAlert(with message: String) {
        display?.displayAlert(with: message)
    }
    
    func present(_ photos: [FlickrPhoto]) {
        display?.display(photos)
    }
}

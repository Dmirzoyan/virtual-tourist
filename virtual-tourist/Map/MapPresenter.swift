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
    func display(_ viewState: PopupViewState)
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
        let viewState = PopupViewState(isLoading: false, items: photos.map {
            return PopupItemViewState(thumbnail: $0.thumbnail, title: $0.title)
        })
        
        display?.display(viewState)
    }
    
    func presentLoadingProgress() {
        display?.display(PopupViewState(isLoading: true, items: []))
    }
}

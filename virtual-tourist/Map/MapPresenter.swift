//
//  MapPresenter.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 6/24/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol MapDisplaying {
    func display(_ viewState: PopupViewState)
    func displayAlert(with message: String)
}

final class MapPresenter: MapPresenting {
    
    private var display: MapDisplaying?
    private var viewState = PopupViewState.default
    
    init(display: MapDisplaying) {
        self.display = display
    }
    
    func preview(_ address: Address) {
        viewState.set {
            $0.set(address: address)
        }
        
        display?.display(viewState)
    }
    
    func presentAlert(with message: String) {
        display?.displayAlert(with: message)
    }
    
    func present(_ photos: [FlickrPhoto]) {
        viewState.set {
            $0.set(isLoading: false)
            $0.items = photos.map {
                return PopupItemViewState(thumbnail: $0.thumbnail, title: $0.title)
            }
        }
        
        display?.display(viewState)
    }
    
    func presentLoadingProgress() {
        viewState.set {
            $0.set(isLoading: true)
            $0.set(items: [])
        }
        
        display?.display(viewState)
    }
}

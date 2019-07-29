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
    func display(_ pins: [Pin])
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
    
    func presentLoadingProgress() {
        viewState.set {
            $0.set(isLoading: true)
            $0.set(items: [])
        }
        
        display?.display(viewState)
    }
    
    func present(_ pins: [Pin]) {
        display?.display(pins)
    }
    
    func present(_ photos: [Photo]) {
        viewState.set {
            $0.set(isLoading: false)
            $0.items = photos.filter({ $0.title != nil && $0.thumbnailData != nil }).map {
                return PopupItemViewState(thumbnail: UIImage(data: $0.thumbnailData!), title: $0.title!)
            }
        }
        
        display?.display(viewState)
    }
}

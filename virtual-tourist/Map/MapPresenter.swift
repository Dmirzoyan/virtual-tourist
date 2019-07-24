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
        viewState.set(address: address)
        viewState.changes = PopupViewStateChanges(address: .changed)
        display?.display(viewState)
    }
    
    func presentAlert(with message: String) {
        display?.displayAlert(with: message)
    }
    
    func present(_ photos: [FlickrPhoto]) {
        viewState.set(isLoading: false)
        viewState.set(items: photos.map {
            return PopupItemViewState(thumbnail: $0.thumbnail, title: $0.title)
        })
        viewState.changes = PopupViewStateChanges(isLoading: .changed, items: .changed)
        
        display?.display(viewState)
    }
    
    func presentLoadingProgress() {
        viewState.set(isLoading: true)
        viewState.set(items: [])
        viewState.changes = PopupViewStateChanges(isLoading: .changed, items: .changed)
        
        display?.display(viewState)
    }
}

//
//  PopupViewState.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/21/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

enum Change { case changed, unchanged }

struct PopupViewState {
    private(set) var isLoading: Bool
    private(set) var address: Address
    private(set) var items: [PopupItemViewState]
    
    var changes: PopupViewStateChanges
    
    static var `default` = PopupViewState(
        isLoading: true,
        address: Address(city: "", street: ""),
        items: [],
        changes: PopupViewStateChanges()
    )
    
    mutating func set(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    mutating func set(address: Address) {
        self.address = address
    }
    
    mutating func set(items: [PopupItemViewState]) {
        self.items = items
    }
}

struct PopupItemViewState {
    let thumbnail: UIImage?
    let title: String
}

struct PopupViewStateChanges {
    let isLoading: Change
    let address: Change
    let items: Change
    
    init(
        isLoading: Change = .unchanged,
        address: Change = .unchanged,
        items: Change = .unchanged
    ) {
        self.isLoading = isLoading
        self.address = address
        self.items = items
    }
}

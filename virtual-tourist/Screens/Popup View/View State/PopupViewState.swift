//
//  PopupViewState.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/21/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

struct PopupViewState {
    private(set) var isLoading: Bool
    private(set) var address: Address
    var items: [PopupItemViewState]
    
    var changes: PopupViewStateChanges
    
    static var `default` = PopupViewState(
        isLoading: true,
        address: Address(city: "", street: ""),
        items: [],
        changes: PopupViewStateChanges()
    )
    
    mutating func set(_ updates: (inout PopupViewState) -> Void) {        
        changes = PopupViewStateChanges()
        updates(&self)
    }
    
    mutating func set(isLoading: Bool) {
        self.isLoading = isLoading
        self.changes.isLoading = .changed
    }
    
    mutating func set(address: Address) {
        self.address = address
        self.changes.address = .changed
    }
    
    mutating func set(items: [PopupItemViewState]) {
        self.items = items
        self.changes.items = .changed
    }
}

struct PopupItemViewState {
    let thumbnail: UIImage?
    let title: String
}

enum Change { case changed, unchanged }

extension Change {
    var isChanged: Bool {
        switch self {
        case .changed:
            return true
        case .unchanged:
            return false
        }
    }
}

struct PopupViewStateChanges {
    var isLoading: Change
    var address: Change
    var items: Change
    
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

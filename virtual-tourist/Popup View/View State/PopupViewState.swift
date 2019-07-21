//
//  PopupViewState.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/21/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

struct PopupViewState {
    let isLoading: Bool
    let items: [PopupItemViewState]
}

struct PopupItemViewState {
    let thumbnail: UIImage?
    let title: String
}

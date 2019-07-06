//
//  PopupView.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

final class PopupView: UIView {
    
    override func layoutSubviews() {
        backgroundColor = .darkGray
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}

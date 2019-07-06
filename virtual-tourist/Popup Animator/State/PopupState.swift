//
//  PopupState.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

enum PopupState {
    case open, closed
}

extension PopupState {
    var opposite: PopupState {
        switch self {
        case .open:
            return .closed
        case .closed:
            return .open
        }
    }
}

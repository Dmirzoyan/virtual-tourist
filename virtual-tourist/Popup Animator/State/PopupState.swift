//
//  PopupState.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019. All rights reserved.
//

enum PopupState {
    case open, preview, closed
}

extension PopupState {
    
    var next: PopupState {
        switch self {
        case .closed:
            return .preview
        case .preview:
            return .open
        case .open:
            return .preview
        }
    }
}

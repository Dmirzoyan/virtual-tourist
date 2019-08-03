//
//  TextAttributes.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/20/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

struct TextAttributes {
    
    static var largeHeavy: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy-Bold", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    static var mediumLight: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy-Light", size: 15)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    static var small: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy-Light", size: 12)!,
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
    }
    
    static var mediumHeavy: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy-Bold", size: 15)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
}

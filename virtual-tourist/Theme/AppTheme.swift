//
//  AppTheme.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/20/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

extension UIColor {
    
    struct AppTheme {
        static var green: UIColor  {
            return UIColor(red: 0, green: 204 / 256, blue: 153 / 256, alpha: 1)
        }
        
        static var dargGray: UIColor {
            return UIColor(displayP3Red: 38 / 255, green: 38 / 255, blue: 38 / 255, alpha: 1)
        }
        
        static var darkBlue: UIColor {
            return UIColor(red: 20 / 256, green: 23 / 256, blue: 40 / 256, alpha: 1)
        }
        
        static var lightGray: UIColor {
            return UIColor(red: 236 / 256, green: 240 / 256, blue: 241 / 256, alpha: 1)
        }
        
        static var midGray: UIColor {
            return UIColor(red: 160 / 256, green: 164 / 256, blue: 166 / 256, alpha: 1)
        }
        
        static var lightRed: UIColor {
            return UIColor(displayP3Red: 255 / 255, green: 118 / 255, blue: 118 / 255, alpha: 1)
        }
    }
}

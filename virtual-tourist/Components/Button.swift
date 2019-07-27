//
//  Button.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/27/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func expandAnimate(duration: Double, alpha: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            self.transform = CGAffineTransform.identity
            self.alpha = alpha
        })
        animator.startAnimation()
    }
    
    func shrinkAnimate(duration: Double, alpha: CGFloat, scaleX: CGFloat, scaleY: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            self.alpha = alpha
        })
        animator.startAnimation()
    }
}

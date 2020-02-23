//
//  RoundButton.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 8/2/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

final class RoundButton: UIButton {
    
    var width: CGFloat!
    var delegate: ButtonDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = width / 2
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: width),
        ])
        
        addShadow()
        
        addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(buttonReleased(_:)), for: .touchCancel)
    }
    
    private func addShadow() {
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.masksToBounds = false
    }
    
    @objc private func buttonPressed(_ sender: DecoratedButton) {
        animateShadow(height: 7, radius: 6)
    }
    
    @objc private func buttonReleased(_ sender: DecoratedButton) {
        animateShadow(height: 2, radius: 2)
        delegate?.isPressed()
    }
    
    private func animateShadow(height: CGFloat, radius: CGFloat) {
        let offsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        offsetAnimation.fromValue = layer.shadowOffset
        offsetAnimation.toValue = CGSize(width: 0, height: height)
        offsetAnimation.duration = 0.15
        offsetAnimation.fillMode = CAMediaTimingFillMode.forwards
        offsetAnimation.isRemovedOnCompletion = false
        
        let radiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnimation.fromValue = layer.shadowOffset
        radiusAnimation.toValue = radius
        radiusAnimation.duration = 0.15
        radiusAnimation.fillMode = CAMediaTimingFillMode.forwards
        radiusAnimation.isRemovedOnCompletion = false
        
        layer.add(offsetAnimation, forKey: offsetAnimation.keyPath)
        layer.add(radiusAnimation, forKey: radiusAnimation.keyPath)
    }
}

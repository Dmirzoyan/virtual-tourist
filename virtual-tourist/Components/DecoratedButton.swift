//
//  Button.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/20/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol ButtonDelegate {
    func isPressed()
}

final class DecoratedButton: Button {
    
    var width: CGFloat!
    var height: CGFloat!
    var delegate: ButtonDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 25
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height),
        ])
        
        addShadow()
        
        addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(buttonReleased(_:)), for: .touchCancel)
    }
    
    private func addShadow() {
        let contactRect = CGRect(x: width * 0.05, y: height * 0.08, width: width * 0.9, height: height * 1.05)
        layer.shadowPath = UIBezierPath(roundedRect: contactRect, cornerRadius: 30).cgPath
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.8
        layer.shadowColor = UIColor.black.cgColor
        layer.masksToBounds = false
    }
    
    @objc private func buttonPressed(_ sender: DecoratedButton) {
        sender.shrinkAnimate(duration: 0.1, alpha: 1, scaleX: 0.95, scaleY: 0.95)
    }
    
    @objc private func buttonReleased(_ sender: DecoratedButton) {
        sender.expandAnimate(duration: 0.1, alpha: 1)
        delegate?.isPressed()
    }
}

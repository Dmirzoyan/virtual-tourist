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

final class Button: UIButton {
    
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
    
    @objc private func buttonPressed(_ sender: Button) {
        sender.shrink()
    }
    
    @objc private func buttonReleased(_ sender: Button) {
        sender.expand()
        delegate?.isPressed()
    }
    
    private func shrink() {
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
        animator.startAnimation()
    }
    
    private func expand() {
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeOut, animations: {
            self.transform = CGAffineTransform.identity
        })
        animator.startAnimation()
    }
}

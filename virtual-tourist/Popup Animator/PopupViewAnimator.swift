//
//  PopupViewAnimator.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

protocol PopupViewAnimating {
    func animateTransitionIfNeeded(duration: TimeInterval)
}

final class PopupViewAnimator: PopupViewAnimating {
    
    private var animator: UIViewPropertyAnimator!
    private let hostView: UIView
    private let popupView: PopupView
    private let offset: CGFloat
    private var state: PopupState
    private var bottomConstraint = NSLayoutConstraint()
    
    init(hostView: UIView, popupView: PopupView, initialState: PopupState, offset: CGFloat) {
        self.hostView = hostView
        self.popupView = popupView
        self.state = initialState
        self.offset = offset
        
        layout()
    }
    
    private func layout() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(popupView)
        
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: hostView.bottomAnchor, constant: offset)
        
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            bottomConstraint,
            popupView.heightAnchor.constraint(equalToConstant: 500),
        ])
    }
    
    func animateTransitionIfNeeded(duration: TimeInterval) {
        animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch self.state.opposite {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
            case .closed:
                self.bottomConstraint.constant = self.offset
                self.popupView.layer.cornerRadius = 0
            }
            self.hostView.layoutIfNeeded()
        })
        
        animator.addCompletion { [weak self] _ in
            guard let strongSelf = self
            else { return }
            
            strongSelf.state = strongSelf.state.opposite
        }
        animator.startAnimation()
    }
}

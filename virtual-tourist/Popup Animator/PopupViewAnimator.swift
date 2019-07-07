//
//  PopupViewAnimator.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

protocol PopupViewAnimating {
    func animateTransitionIfNeeded(offset: CGFloat, duration: TimeInterval)
}

final class PopupViewAnimator: PopupViewAnimating {
    
    private var animator: UIViewPropertyAnimator!
    private let hostView: UIView
    private let popupView: PopupView
    private var state: PopupState
    private let popupViewHeight: CGFloat
    private var bottomConstraint = NSLayoutConstraint()
    
    init(hostView: UIView, popupView: PopupView, popupViewHeight: CGFloat, initialState: PopupState) {
        self.hostView = hostView
        self.popupView = popupView
        self.popupViewHeight = popupViewHeight
        self.state = initialState
        
        layout()
    }
    
    private func layout() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(popupView)
        
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: hostView.bottomAnchor, constant: popupViewHeight)
        
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            bottomConstraint,
            popupView.heightAnchor.constraint(equalToConstant: popupViewHeight),
        ])
    }
    
    func animateTransitionIfNeeded(offset: CGFloat, duration: TimeInterval) {
        animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch self.state.next {
            case .preview:
                self.bottomConstraint.constant = self.popupViewHeight - offset
                self.popupView.layer.cornerRadius = 20
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
            case .closed:
                self.bottomConstraint.constant = self.popupViewHeight
                self.popupView.layer.cornerRadius = 0
            }
            self.hostView.layoutIfNeeded()
        })
        
        animator.addCompletion { [weak self] _ in
            guard let strongSelf = self
            else { return }
            
            strongSelf.state = strongSelf.state.next
        }
        animator.startAnimation()
    }
}

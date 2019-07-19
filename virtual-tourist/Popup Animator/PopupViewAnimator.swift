//
//  PopupViewAnimator.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol PopupViewAnimating {
    func animateTransitionIfNeeded(to state: PopupState, duration: TimeInterval)
    var updater: PopupViewStateUpdater? { get set }
}

protocol PopupViewStateUpdater {
    func update(state: PopupState)
}

final class PopupViewAnimator: PopupViewAnimating {
    
    private let hostView: UIView
    private let popupView: PopupView
    private let popupViewHeight: CGFloat
    private let popupPreviewHeight: CGFloat
    private var currentState: PopupState
    
    private var animator = UIViewPropertyAnimator()
    private var isAnimationInProgress = false
    private var animationProgress: CGFloat = 0
    private var viewCornerRadius: CGFloat = 30
    
    private var bottomConstraint = NSLayoutConstraint()
    private lazy var panRecognizer = InstantPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    
    var updater: PopupViewStateUpdater?
    
    init(
        hostView: UIView,
        popupView: PopupView,
        popupViewHeight: CGFloat,
        popupPreviewHeight: CGFloat,
        initialState: PopupState
    ) {
        self.hostView = hostView
        self.popupView = popupView
        self.popupViewHeight = popupViewHeight
        self.popupPreviewHeight = popupPreviewHeight
        self.currentState = initialState
        
        layout()
        
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    private func layout() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(popupView)
        
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: hostView.bottomAnchor, constant: popupViewHeight)
        
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: hostView.leadingAnchor, constant: popupView.borderMargin),
            popupView.trailingAnchor.constraint(equalTo: hostView.trailingAnchor, constant: -popupView.borderMargin),
            bottomConstraint,
            popupView.heightAnchor.constraint(equalToConstant: popupViewHeight),
        ])
    }
    
    func animateTransitionIfNeeded(to state: PopupState, duration: TimeInterval) {
        guard !isAnimationInProgress
        else { return }
        
        animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .preview:
                self.bottomConstraint.constant = self.popupViewHeight - self.popupPreviewHeight
                self.popupView.layer.cornerRadius = self.viewCornerRadius
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = self.viewCornerRadius
            case .closed:
                self.bottomConstraint.constant = self.popupViewHeight
                self.popupView.layer.cornerRadius = 0
            }
            self.hostView.layoutIfNeeded()
        })
        
        animator.addCompletion { [weak self] _ in
            guard let strongSelf = self
            else { return }
            
            if !strongSelf.animator.isReversed {
                strongSelf.currentState = state
            }
            
            switch strongSelf.currentState {
            case .preview:
                strongSelf.bottomConstraint.constant = strongSelf.popupViewHeight - strongSelf.popupPreviewHeight
            case .open:
                strongSelf.bottomConstraint.constant = 0
            case .closed:
                strongSelf.bottomConstraint.constant = strongSelf.popupViewHeight
            }
            strongSelf.updater?.update(state: strongSelf.currentState)
            
            strongSelf.isAnimationInProgress = false
        }
        
        animator.startAnimation()
        isAnimationInProgress = true
    }
    
    @objc
    private func handlePan(recognizer: InstantPanGestureRecognizer) {
        animate(recognizer: recognizer, duration: 0.8)
    }
    
    private func animate(recognizer: InstantPanGestureRecognizer, duration: TimeInterval) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(duration: duration)
        case .changed:
            updateInteractiveTransition(recognizer: recognizer)
        case .ended:
            continueInteractiveTransition(recognizer: recognizer)
        default:
            ()
        }
    }
    
    private func startInteractiveTransition(duration: TimeInterval) {
        animateTransitionIfNeeded(to: currentState.next, duration: duration)
        animator.pauseAnimation()
        animationProgress = animator.fractionComplete
    }
    
    private func updateInteractiveTransition(recognizer: InstantPanGestureRecognizer) {
        let translation = recognizer.translation(in: popupView)
        var fraction = translation.y / (popupViewHeight - popupPreviewHeight)
        
        if  currentState.next == .open {
            fraction *= -1
        }
        
        if animator.isReversed {
            fraction *= -1
        }
        
        animator.fractionComplete = fraction + animationProgress
    }
    
    private func continueInteractiveTransition(recognizer: InstantPanGestureRecognizer) {
        let yVelocity = recognizer.velocity(in: popupView).y
        let isClosing = yVelocity > 0

        if yVelocity == 0 {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            return
        }
        
        if (((currentState.next == .open) && isClosing) ||
            ((currentState.next == .closed) && !isClosing) ||
            ((currentState.next == .preview) && !isClosing)) {
            animator.isReversed = true
        }
        
        animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
}

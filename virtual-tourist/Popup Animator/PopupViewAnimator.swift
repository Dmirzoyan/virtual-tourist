//
//  PopupViewAnimator.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol PopupViewAnimating {
    func animateTransitionIfNeeded(to state: PopupState, isInteractionEnabled: Bool, duration: TimeInterval)
    var currentState: PopupState { get }
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
    var currentState: PopupState
    
    private var animator = UIViewPropertyAnimator()
    private var isAnimationInProgress = false
    private var isAnimationInteractionEnabled = true
    private var animationProgress: CGFloat = 0
    private var viewCornerRadius: CGFloat = 30
    
    private var bottomConstraint: NSLayoutConstraint
    private lazy var panRecognizer = InstantPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    
    var updater: PopupViewStateUpdater?
    
    init(
        hostView: UIView,
        popupView: PopupView,
        popupViewHeight: CGFloat,
        popupPreviewHeight: CGFloat,
        initialState: PopupState,
        bottomConstraint: NSLayoutConstraint
    ) {
        self.hostView = hostView
        self.popupView = popupView
        self.popupViewHeight = popupViewHeight
        self.popupPreviewHeight = popupPreviewHeight
        self.currentState = initialState
        self.bottomConstraint = bottomConstraint
        
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    func animateTransitionIfNeeded(to state: PopupState, isInteractionEnabled: Bool, duration: TimeInterval) {
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
            strongSelf.isAnimationInteractionEnabled = true
        }
        
        animator.startAnimation()
        isAnimationInProgress = true
        isAnimationInteractionEnabled = isInteractionEnabled
    }
    
    @objc
    private func handlePan(recognizer: InstantPanGestureRecognizer) {
        guard isAnimationInteractionEnabled
        else { return }
        
        animate(recognizer: recognizer, duration: 0.8)
    }
    
    func animate(recognizer: InstantPanGestureRecognizer, duration: TimeInterval) {
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
        animateTransitionIfNeeded(to: currentState.next, isInteractionEnabled: true, duration: duration)
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
        } else {
            animator.isReversed = false
        }
        
        animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
//        self.state = UIGestureRecognizer.State.began
    }
}

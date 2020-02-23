//
//  AnimationCoordinator.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 8/3/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit
import GoogleMaps

protocol AnimationCoordinating {
    func animateViewChange(to state: PopupState)
}

final class AnimationCoordinator: AnimationCoordinating {
    
    private let parentView: UIView
    private let mapView: GMSMapView
    private let deletePinButton: RoundButton
    private let popupPreviewHeight: CGFloat
    private let popupViewAnimator: PopupViewAnimating
    private let deletePinButtonBottomConstraint: NSLayoutConstraint
    
    
    private let animationDuration = 0.8
    private let deletePinButtonBottomPadding: CGFloat = 80
    
    init(
        parentView: UIView,
        mapView: GMSMapView,
        deletePinButton: RoundButton,
        popupPreviewHeight: CGFloat,
        popupViewAnimator: PopupViewAnimating,
        deletePinButtonBottomConstraint: NSLayoutConstraint
    ) {
        self.parentView = parentView
        self.mapView = mapView
        self.deletePinButton = deletePinButton
        self.popupViewAnimator = popupViewAnimator
        self.popupPreviewHeight = popupPreviewHeight
        self.deletePinButtonBottomConstraint = deletePinButtonBottomConstraint
    }
    
    func animateViewChange(to state: PopupState) {
        popupViewAnimator.animateTransitionIfNeeded(
            to: state,
            isInteractionEnabled: false,
            duration: animationDuration
        )
        animateMapPadding(height: state == .preview ? popupPreviewHeight : 0)
        
        deletePinButton.isEnabled = state == .preview
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.deletePinButton.backgroundColor = state == .preview ? UIColor.AppTheme.lightRed : UIColor.white.withAlphaComponent(0.8)
        }
        animator.startAnimation()
    }
    
    private func animateMapPadding(height: CGFloat) {
        let animator = UIViewPropertyAnimator.init(duration: animationDuration, dampingRatio: 1) {
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            self.deletePinButtonBottomConstraint.constant = -self.deletePinButtonBottomPadding - height
            self.parentView.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}

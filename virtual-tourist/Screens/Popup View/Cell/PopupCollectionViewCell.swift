//
//  PopupTableViewCell.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/7/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

enum DeleteCompletionType { case cancel, delete}

final class PopupCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var deleteButton: Button!
    
    private var deleteCompletion: ((DeleteCompletionType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deleteCompletion?(.cancel)
        deleteButton.shrinkAnimate(duration: 0.01, alpha: 0, scaleX: 0.2, scaleY: 0.2)
        overlayView.backgroundColor = UIColor.clear
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        deleteCompletion?(.delete)
    }
    
    private func setStyle() {
        setCellStyle()
        setImageStyle()
    }
    
    private func setCellStyle() {
        containerView.layer.cornerRadius = 15
        overlayView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        addShadow(on: self.layer, height: 5, opacity: 0.2, radius: 4)
        
        deleteButton.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        deleteButton.layer.cornerRadius = 16
    }
    
    private func setImageStyle() {
        imageView.layer.maskedCorners = [ .layerMaxXMaxYCorner ]
        imageView.layer.cornerRadius = 25
        addShadow(on: imageContainerView.layer, height: 1, opacity: 0.6, radius: 2)
    }
    
    private func addShadow(on layer: CALayer, height: CGFloat, opacity: Float, radius: CGFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func prepareToDelete(completion: @escaping (DeleteCompletionType) -> Void) {
        animateForDeletion()
        deleteCompletion = completion
    }
    
    private func animateForDeletion() {
        shakeAnimateCell()
        animateOverlay(toAdd: true)
        deleteButton.expandAnimate(duration: 0.3, alpha: 1)
    }
    
    func cancelDeletion() {
        layer.removeAnimation(forKey: "animate")
        animateOverlay(toAdd: false)
        deleteButton.shrinkAnimate(duration: 0.3, alpha: 0, scaleX: 0.2, scaleY: 0.2)
    }
    
    private func shakeAnimateCell() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        let startAngle: Float = (-2) * 3.14159/270
        let stopAngle = -startAngle
        
        animation.duration = 0.12
        animation.repeatCount = 99999
        animation.fromValue = NSNumber(value: startAngle as Float)
        animation.toValue = NSNumber(value: stopAngle as Float)
        animation.autoreverses = true
        animation.timeOffset = 290 * drand48()
        
        layer.add(animation, forKey:"animate")
    }
    
    private func animateOverlay(toAdd: Bool) {
        let animator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
            if toAdd {
                self.overlayView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            } else {
                self.overlayView.backgroundColor = UIColor.clear
            }
        }
        animator.startAnimation()
    }
}

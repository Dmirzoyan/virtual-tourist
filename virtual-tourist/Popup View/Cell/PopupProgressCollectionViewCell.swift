//
//  PopupTableViewCell.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/7/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

final class PopupProgressCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    private let imageContainerGradient = CAGradientLayer()
    private let labelContainerGradient = CAGradientLayer()
    private let colorAnimation = CABasicAnimation(keyPath: "colors")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        
        setupGradientAnimation()
        setupGradients()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageContainerGradient.frame = imageContainerView.bounds
        labelContainerGradient.frame = labelContainerView.bounds
    }
    
    private func setupGradients() {
        setup(gradient: imageContainerGradient, for: imageContainerView)
        setup(gradient: labelContainerGradient, for: labelContainerView)
    }
    
    private func setup(gradient: CAGradientLayer, for view: UIView) {
        gradient.colors = [UIColor.AppTheme.lightGray.cgColor, UIColor.AppTheme.midGray.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.locations = [-0.4, 1.4]
        view.layer.addSublayer(gradient)
        gradient.add(colorAnimation, forKey: nil)
    }
    
    private func setupGradientAnimation() {
        colorAnimation.fromValue = [UIColor.AppTheme.lightGray.cgColor, UIColor.AppTheme.midGray.cgColor]
        colorAnimation.toValue = [UIColor.AppTheme.midGray.cgColor, UIColor.AppTheme.lightGray.cgColor]
        colorAnimation.duration = 1
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = Float.infinity
    }
}

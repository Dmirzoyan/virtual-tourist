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
    @IBOutlet weak var deleteButton: UIButton!
    
    private var deleteCompletion: ((DeleteCompletionType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setStyle()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        deleteCompletion?(.delete)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deleteCompletion?(.cancel)
        deleteButton.isHidden = true
        overlayView.backgroundColor = UIColor.clear
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
        
        deleteButton.backgroundColor = UIColor.lightGray
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
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        let startAngle: Float = (-2) * 3.14159/270
        let stopAngle = -startAngle
        
        shakeAnimation.duration = 0.12
        shakeAnimation.repeatCount = 99999
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.timeOffset = 290 * drand48()
        
        layer.add(shakeAnimation, forKey:"animate")
        
        deleteButton.isHidden = false
        overlayView.backgroundColor = UIColor.init(white: 0.4, alpha: 0.5)
        
        deleteCompletion = completion
    }
    
    func cancelDeletion() {
        layer.removeAnimation(forKey: "animate")
        deleteButton.isHidden = true
        overlayView.backgroundColor = UIColor.clear
    }
}

//
//  PopupTableViewCell.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/7/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

final class PopupCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setStyle() {
        setCellStyle()
        setImageStyle()
    }
    
    private func setCellStyle() {
        containerView.layer.cornerRadius = 6.0
        containerView.layer.masksToBounds = true
        addShadow(on: self.layer, height: 5, opacity: 0.2, radius: 4)
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
}

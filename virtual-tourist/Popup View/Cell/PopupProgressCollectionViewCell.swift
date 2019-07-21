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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        imageContainerView.backgroundColor = UIColor.AppTheme.lightGray
        labelContainerView.backgroundColor = UIColor.AppTheme.lightGray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

//
//  PopupView.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

final class PopupView: UIView {
    
    private var streetLabel: UILabel!
    private var cityLabel: UILabel!
    
    private var streetTextAttributes: [NSAttributedString.Key: Any] {
        return [
//            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 18)!
        ]
    }
    
    private var cityTextAttributes: [NSAttributedString.Key: Any] {
        return [
            //            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "ArialMT", size: 15)!
        ]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .white
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        addShadow()
        layoutTitle()
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
    }
    
    private func layoutTitle() {
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleView)
        
        streetLabel = addLabel(to: titleView)
        cityLabel = addLabel(to: titleView)
        
        NSLayoutConstraint.activate([
            streetLabel.widthAnchor.constraint(equalToConstant: 300),
            cityLabel.widthAnchor.constraint(equalTo: streetLabel.widthAnchor),
            cityLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 3),
            titleView.widthAnchor.constraint(equalTo: streetLabel.widthAnchor),
            titleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
        ])
    }
    
    private func addLabel(to view: UIView) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        view.addSubview(label)
        
        return label
    }
    
    func set(street: String, city: String) {
        streetLabel.attributedText = NSAttributedString(string: street, attributes: streetTextAttributes)
        cityLabel.attributedText = NSAttributedString(string: city, attributes: cityTextAttributes)
    }
}

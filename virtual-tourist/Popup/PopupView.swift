//
//  PopupView.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

final class PopupView: UIView {
    
    let borderMargin: CGFloat = 5
    
    private var streetLabel: UILabel!
    private var cityLabel: UILabel!
    private var titleContainer: UIView!
    private var collectionView: UICollectionView!
    private var itemCount = 0
    
    private struct ViewMeasures {
        static let interItemPadding: CGFloat = 5
        static let nrItemsPerRow: CGFloat = 3
    }
    
    private var streetTextAttributes: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy-Bold", size: 18)!
        ]
    }
    
    private var cityTextAttributes: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont(name: "Noteworthy-Light", size: 15)!
        ]
    }
    
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let itemSize = ((UIScreen.main.bounds.width - 2 * borderMargin) - (ViewMeasures.nrItemsPerRow + 1)
            * ViewMeasures.interItemPadding) / ViewMeasures.nrItemsPerRow
        
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = ViewMeasures.interItemPadding
        layout.minimumLineSpacing = ViewMeasures.interItemPadding
        layout.sectionInset = UIEdgeInsets(
            top: ViewMeasures.interItemPadding,
            left: ViewMeasures.interItemPadding,
            bottom: ViewMeasures.interItemPadding,
            right: ViewMeasures.interItemPadding
        )
        return layout
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
        setupCollectionView()
    }
    
    func set(street: String, city: String) {
        streetLabel.attributedText = NSAttributedString(string: street, attributes: streetTextAttributes)
        cityLabel.attributedText = NSAttributedString(string: city, attributes: cityTextAttributes)
    }
    
    func set(itemcCount: Int) {
        self.itemCount = itemcCount
        collectionView.reloadData()
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
    }
    
    private func layoutTitle() {
        titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleContainer)
        
        addTitleContent()
        
        NSLayoutConstraint.activate([
            titleContainer.widthAnchor.constraint(equalTo: streetLabel.widthAnchor),
            titleContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleContainer.topAnchor.constraint(equalTo: topAnchor, constant: 20)
        ])
    }
    
    private func addTitleContent() {
        streetLabel = addLabel(to: titleContainer)
        cityLabel = addLabel(to: titleContainer)
        
        NSLayoutConstraint.activate([
            streetLabel.widthAnchor.constraint(equalToConstant: 300),
            streetLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            cityLabel.widthAnchor.constraint(equalTo: streetLabel.widthAnchor),
            cityLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor),
            cityLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
        ])
    }
    
    private func addLabel(to view: UIView) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        view.addSubview(label)
        
        return label
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor)
        ])
        
        let nib = UINib.init(nibName: "PopupCollectionViewCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "PopupCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
    }
}

extension PopupView: UICollectionViewDelegate {}

extension PopupView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PopupCollectionViewCell", for: indexPath
        ) as! PopupCollectionViewCell
        
        cell.imageView.image = nil
        
        return cell
    }
}

//
//  PopupView.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

final class PopupView: UIView {
    
    static let borderMargin: CGFloat = 5
    
    private var streetLabel: UILabel!
    private var cityLabel: UILabel!
    private var titleContainer: UIView!
    private var collectionView: UICollectionView!
    private var items: [FlickrPhoto] = []
    
    private struct ViewMeasures {
        static let interItemPadding: CGFloat = 15
        static let nrItemsPerRow: CGFloat = 3
        static let itemWidth = ((UIScreen.main.bounds.width - 2 * borderMargin) -
            (nrItemsPerRow + 1) * interItemPadding) / nrItemsPerRow
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
        
        layout.itemSize = CGSize(width: ViewMeasures.itemWidth, height: ViewMeasures.itemWidth * 1.6)
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
    
    func set(items: [FlickrPhoto]) {
        self.items = items
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
            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 13)
        ])
        
        let nib = UINib.init(nibName: "PopupCollectionViewCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "PopupCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
//        collectionView.bounces = true
//        collectionView.isScrollEnabled = true
//        collectionView.isUserInteractionEnabled = true
//        collectionView.alwaysBounceVertical = true
    }
}

extension PopupView: UICollectionViewDelegate {}

extension PopupView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PopupCollectionViewCell", for: indexPath
        ) as! PopupCollectionViewCell
        
        cell.imageView.image = items[indexPath.item].thumbnail
        
        return cell
    }
}

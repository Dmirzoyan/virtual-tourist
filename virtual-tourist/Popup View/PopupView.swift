//
//  PopupView.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/6/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol PopupViewDelegate {
    func getNewImagesButtonPressed()
}

final class PopupView: UIView {
    
    static let borderMargin: CGFloat = 5
    
    private var streetLabel: UILabel!
    private var cityLabel: UILabel!
    private var titleContainer: UIView!
    private var button: Button!
    private var collectionView: UICollectionView!
    private let dataSource = PopupViewDataSource()
    
    var delegate: PopupViewDelegate?
    
    private struct ViewMeasures {
        static let buttonWidth: CGFloat = 200
        static let buttonHeight: CGFloat = 50
        static let interItemPadding: CGFloat = 25
        static let nrItemsPerRow: CGFloat = 2
        static let itemWidth = ((UIScreen.main.bounds.width - 2 * borderMargin) -
            (nrItemsPerRow + 1) * interItemPadding) / nrItemsPerRow
    }
    
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: floor(ViewMeasures.itemWidth), height: ViewMeasures.itemWidth * 1.6)
        layout.minimumInteritemSpacing = ViewMeasures.interItemPadding
        layout.minimumLineSpacing = ViewMeasures.interItemPadding
        layout.scrollDirection = .horizontal
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
        backgroundColor = UIColor.AppTheme.creamyGray
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        addShadow()
        addContainer()
        layoutTitle()
        setupButton()
        setupCollectionView()
    }
    
    func set(street: String, city: String) {
        streetLabel.attributedText = NSAttributedString(string: street, attributes: TextAttributes.largeHeavy)
        cityLabel.attributedText = NSAttributedString(string: city, attributes: TextAttributes.mediumLight)
    }
    
    func set(viewState: PopupViewState) {
        dataSource.set(viewState)
        collectionView.reloadData()
    }
    
    private func addContainer() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        container.backgroundColor = UIColor.AppTheme.darkBlue
        container.layer.maskedCorners = [ .layerMinXMinYCorner ]
        container.layer.cornerRadius = 30
        
        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 300)
        ])
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
    
    private func setupButton() {
        button = Button()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.AppTheme.green
        button.width = ViewMeasures.buttonWidth
        button.height = ViewMeasures.buttonHeight
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),            
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
        
        button.setAttributedTitle(NSAttributedString(
            string: "NEW IMAGES",
            attributes: TextAttributes.mediumHeavy
        ), for: .normal)
    }
    
    @objc private func buttonPressed(_ sender: Button) {
        delegate?.getNewImagesButtonPressed()
        sender.pulsate()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 13)
        ])
        
        let nib = UINib.init(nibName: "PopupCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PopupCollectionViewCell")
        
        let nib2 = UINib.init(nibName: "PopupProgressCollectionViewCell", bundle: nil)
        collectionView.register(nib2, forCellWithReuseIdentifier: "PopupProgressCollectionViewCell")
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .clear
    }
}

extension PopupView: UICollectionViewDelegate {}

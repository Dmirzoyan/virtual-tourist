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
    private var titleContainer: UIView!
    private var tableView: UITableView!
    
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
        setupTableView()
    }
    
    func set(street: String, city: String) {
        streetLabel.attributedText = NSAttributedString(string: street, attributes: streetTextAttributes)
        cityLabel.attributedText = NSAttributedString(string: city, attributes: cityTextAttributes)
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
            cityLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 3),
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
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor)
        ])
        
        let nib = UINib.init(nibName: "PopupTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "PopupTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension PopupView: UITableViewDelegate {
    
}

extension PopupView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PopupTableViewCell", for: indexPath
        ) as! PopupTableViewCell
        
        cell.locationImageView.image = nil
        
        return cell
    }
}

//
//  PopupViewDataSource.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/21/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

protocol PopupViewDataProviding {
    func getItems() -> [PopupItemViewState]
    func set(_ viewState: PopupViewState)
    func deleteItem(at indexPath: IndexPath)
}

final class PopupViewDataSource: NSObject, UICollectionViewDataSource {
    
    private var viewState: PopupViewState?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewState = viewState
        else { return 0}
        
        return viewState.isLoading ? 2 : viewState.items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let viewState = viewState
        else { return UICollectionViewCell() }
        
        return viewState.isLoading ? progressCell(collectionView, indexPath: indexPath) :
            imageCell(collectionView, indexPath: indexPath, viewState: viewState)
    }
    
    private func progressCell(
        _ collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> PopupProgressCollectionViewCell {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "PopupProgressCollectionViewCell", for: indexPath
        ) as! PopupProgressCollectionViewCell
    }
    
    private func imageCell(
        _ collectionView: UICollectionView,
        indexPath: IndexPath,
        viewState: PopupViewState
    ) -> PopupCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PopupCollectionViewCell", for: indexPath
        ) as! PopupCollectionViewCell
        
        cell.imageView.image = viewState.items[indexPath.item].thumbnail
        cell.label.attributedText = NSAttributedString(
            string: viewState.items[indexPath.item].title,
            attributes: TextAttributes.small
        )
        
        return cell
    }
}

extension PopupViewDataSource: PopupViewDataProviding {
    
    func getItems() -> [PopupItemViewState] {
        return viewState?.items ?? []
    }
    
    func set(_ viewState: PopupViewState) {
        self.viewState = viewState
    }
    
    func deleteItem(at indexPath: IndexPath) {
        viewState?.items.remove(at: indexPath.row)
    }
}


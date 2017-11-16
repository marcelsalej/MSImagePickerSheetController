//
//  SheetPreviewCollectionViewCell.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//
//

import UIKit

class SheetPreviewCollectionViewCell: SheetCollectionViewCell {
    
    var collectionView: PreviewCollectionView? {
        willSet {
            if let collectionView = collectionView {
                collectionView.removeFromSuperview()
            }
            
            if let collectionView = newValue {
                addSubview(collectionView)
            }
        }
    }
    
    // MARK: - Other Methods
    
    override func prepareForReuse() {
        collectionView = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView?.frame = UIEdgeInsetsInsetRect(bounds, backgroundInsets)
    }
    
}


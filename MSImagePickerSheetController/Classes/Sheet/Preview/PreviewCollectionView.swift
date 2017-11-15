//
//  PreviewCollectionView.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//
//

import UIKit

class PreviewCollectionView: UICollectionView {
    
    var bouncing: Bool {
        if contentOffset.x < -contentInset.left { return true }
        if contentOffset.x + frame.width > contentSize.width + contentInset.right { return true }
        return false
    }
    
    var imagePreviewLayout: PreviewCollectionViewLayout {
        return collectionViewLayout as! PreviewCollectionViewLayout
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: PreviewCollectionViewLayout())
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        panGestureRecognizer.addTarget(self, action: #selector(PreviewCollectionView.handlePanGesture(gestureRecognizer:)))
    }
    
    // MARK: - Panning
    
    @objc private func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let translation = gestureRecognizer.translation(in: self)
            if translation == CGPoint() {
                if !bouncing {
                    let possibleIndexPath = indexPathForItem(at: gestureRecognizer.location(in: self))
                    if let indexPath = possibleIndexPath {
                        selectItem(at: indexPath, animated: false, scrollPosition: [])
                        delegate?.collectionView?(self, didSelectItemAt: indexPath)
                    }
                }
            }
        }
    }
    
}


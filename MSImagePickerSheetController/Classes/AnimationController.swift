//
//  AnimationController.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//

import UIKit

class AnimationController: NSObject {
    
    let imagePickerSheetController: MSImagePickerSheetController
    let presenting: Bool
    
    // MARK: - Initialization
    
    init(imagePickerSheetController: MSImagePickerSheetController, presenting: Bool) {
        self.imagePickerSheetController = imagePickerSheetController
        self.presenting = presenting
    }
    
    // MARK: - Animation
    
    func animatePresentation(context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        containerView.addSubview(imagePickerSheetController.view)
        
        let sheetOriginY = imagePickerSheetController.sheetCollectionView.frame.origin.y
        imagePickerSheetController.sheetCollectionView.frame.origin.y = containerView.bounds.maxY
        imagePickerSheetController.backgroundView.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.imagePickerSheetController.sheetCollectionView.frame.origin.y = sheetOriginY
            self.imagePickerSheetController.backgroundView.alpha = 1
        }, completion: { _ in
            context.completeTransition(true)
        })
    }
    
     func animateDismissal(context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseIn, animations: { () -> Void in
            self.imagePickerSheetController.sheetCollectionView.frame.origin.y = containerView.bounds.maxY
            self.imagePickerSheetController.backgroundView.alpha = 0
        }, completion: { _ in
            self.imagePickerSheetController.view.removeFromSuperview()
            context.completeTransition(true)
        })
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension AnimationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation(context: transitionContext)
        }
        else {
            animateDismissal(context: transitionContext)
        }
    }
    
}


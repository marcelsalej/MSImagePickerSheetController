//
//  PreviewCollectionViewCell.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//


import UIKit

class PreviewCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let videoIndicatorView: UIImageView = {
        let imageView = UIImageView(image: videoImage)
        imageView.isHidden = true
        
        return imageView
    }()
    
    private class var videoImage: UIImage? {
        let bundle = Bundle(for: ImagePickerSheetController.self)
        let image = UIImage(named: "PreviewCollectionViewCell-video", in: bundle, compatibleWith: nil)
        
        return image
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        addSubview(imageView)
        addSubview(videoIndicatorView)
    }
    
    // MARK: - Other Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        videoIndicatorView.isHidden = true
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        let videoIndicatViewSize = videoIndicatorView.image?.size ?? CGSize()
        let inset: CGFloat = 4
        let videoIndicatorViewOrigin = CGPoint(x: bounds.minX + inset, y: bounds.maxY - inset - videoIndicatViewSize.height)
        videoIndicatorView.frame = CGRect(origin: videoIndicatorViewOrigin, size: videoIndicatViewSize)
    }
}


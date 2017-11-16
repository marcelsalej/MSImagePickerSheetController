//
//  SheetCollectionViewCell.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//
//


import UIKit

enum RoundedCorner {
    case All(CGFloat)
    case Top(CGFloat)
    case Bottom(CGFloat)
    case None
}

class SheetCollectionViewCell: UICollectionViewCell {
    
    var backgroundInsets = UIEdgeInsets() {
        didSet {
            reloadMask()
            reloadSeparator()
            setNeedsLayout()
        }
    }
    
    var roundedCorners = RoundedCorner.None {
        didSet {
            reloadMask()
        }
    }
    
    var separatorVisible = false {
        didSet {
            reloadSeparator()
        }
    }
    
    var separatorColor = UIColor.black {
        didSet {
            separatorView?.backgroundColor = separatorColor
        }
    }
    
    var separatorHeight: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var separatorView: UIView?
    
    override var isHighlighted: Bool {
        didSet {
            reloadBackgroundColor()
        }
    }
    
    var highlightedBackgroundColor: UIColor = .clear {
        didSet {
            reloadBackgroundColor()
        }
    }
    
    var normalBackgroundColor: UIColor = .clear {
        didSet {
            reloadBackgroundColor()
        }
    }
    
    private var needsMasking: Bool {
        guard backgroundInsets == UIEdgeInsets() else {
            return true
        }
        
        switch roundedCorners {
        case .None:
            return false
        default:
            return true
        }
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
        layoutMargins = UIEdgeInsets()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadMask()
        
        separatorView?.frame = CGRect(x: bounds.minY, y: bounds.maxY - separatorHeight, width: bounds.width, height: separatorHeight)
    }
    
    // MARK: - Mask
    
    private func reloadMask() {
        if needsMasking && layer.mask == nil {
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.lineWidth = 0
            maskLayer.fillColor = UIColor.black.cgColor
            
            layer.mask = maskLayer
        }
        
        let layerMask = layer.mask as? CAShapeLayer
        layerMask?.frame = bounds
        layerMask?.path = maskPathWithRect(rect: UIEdgeInsetsInsetRect(bounds, backgroundInsets), roundedCorner: roundedCorners)
    }
    
    private func maskPathWithRect(rect: CGRect, roundedCorner: RoundedCorner) -> CGPath {
        let radii: CGFloat
        let corners: UIRectCorner
        
        switch roundedCorner {
        case .All(let value):
            corners = .allCorners
            radii = value
        case .Top(let value):
            corners = [.topLeft, .topRight]
            radii = value
        case .Bottom(let value):
            corners = [.bottomLeft, .bottomRight]
            radii = value
        case .None:
            return UIBezierPath(rect: rect).cgPath
        }
        
        return UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii)).cgPath
    }
    
    // MARK: - Separator
    
    private func reloadSeparator() {
        if separatorVisible && backgroundInsets.bottom < separatorHeight {
            if separatorView == nil {
                let view = UIView()
                view.backgroundColor = separatorColor
                
                addSubview(view)
                separatorView = view
            }
        }
        else {
            separatorView?.removeFromSuperview()
            separatorView = nil
        }
    }
    
    // MARK - Background
    
    private func reloadBackgroundColor() {
        backgroundColor = isHighlighted ? highlightedBackgroundColor : normalBackgroundColor
    }
    
}


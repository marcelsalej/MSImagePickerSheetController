//
//  PreviewCollectionViewLayout.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//

import UIKit

class PreviewCollectionViewLayout: UICollectionViewFlowLayout {
    
    var invalidationCenteredIndexPath: NSIndexPath?
    
    var showsSupplementaryViews: Bool = true {
        didSet {
            invalidateLayout()
        }
    }
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    private var contentSize = CGSize.zero
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        scrollDirection = .horizontal
    }
    
    // MARK: - Layout
    
    override func prepare() {
        super.prepare()
        
        layoutAttributes.removeAll(keepingCapacity: false)
        contentSize = CGSize.zero
        
        if let collectionView = collectionView,
            let dataSource = collectionView.dataSource,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            var origin = CGPoint(x: sectionInset.left, y: sectionInset.top)
            let numberOfSections = dataSource.numberOfSections?(in: collectionView) ?? 0
            
            for s in 0 ..< numberOfSections {
                let indexPath = IndexPath(item: 0, section: s)
                let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath )
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(origin: origin, size: size ?? CGSize.zero)
                attributes.zIndex = 0
                
                layoutAttributes.append(attributes)
                
                origin.x = attributes.frame.maxX + sectionInset.right
            }
            
            contentSize = CGSize(width: origin.x, height: collectionView.frame.height)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var contentOffset = proposedContentOffset
        if let indexPath = invalidationCenteredIndexPath {
            if let collectionView = collectionView {
                let frame = layoutAttributes[indexPath.section].frame
                contentOffset.x = frame.midX - collectionView.frame.width / 2.0
                
                contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                contentOffset.x = min(contentOffset.x, contentSize.width - collectionView.frame.width + collectionView.contentInset.right)
            }
            invalidationCenteredIndexPath = nil
        }
        
        return super.targetContentOffset(forProposedContentOffset: contentOffset)
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes
            .filter { rect.intersects($0.frame) }
            .reduce([UICollectionViewLayoutAttributes]()) { memo, attributes in
                if let supplementaryAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: attributes.indexPath) {
                    return memo + [attributes, supplementaryAttributes]
                }
                return memo
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.section]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let itemAttributes = layoutAttributesForItem(at: indexPath) {
            
            let inset = collectionView.contentInset
            let bounds = collectionView.bounds
            let contentOffset: CGPoint = {
                var contentOffset = collectionView.contentOffset
                contentOffset.x += inset.left
                contentOffset.y += inset.top
                
                return contentOffset
            }()
            let visibleSize: CGSize = {
                var size = bounds.size
                size.width -= (inset.left+inset.right)
                
                return size
            }()
            let visibleFrame = CGRect(origin: contentOffset, size: visibleSize)
            
            let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section) ?? CGSize.zero
            let originX = max(itemAttributes.frame.minX, min(itemAttributes.frame.maxX - size.width, visibleFrame.maxX - size.width))
            
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            attributes.zIndex = 1
            attributes.isHidden = !showsSupplementaryViews
            attributes.frame = CGRect(origin: CGPoint(x: originX, y: itemAttributes.frame.minY), size: size)
            
            return attributes
        }
        
        return nil
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    
    
    
}


//
//  SheetCollectionViewLayout.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//


import UIKit

class SheetCollectionViewLayout: UICollectionViewLayout {
    
    private var layoutAttributes = [[UICollectionViewLayoutAttributes]]()
    private var invalidatedLayoutAttributes: [[UICollectionViewLayoutAttributes]]?
    private var contentSize = CGSize.zero
    
    // MARK: - Layout
    
    override func prepare() {
        super.prepare()
        
        layoutAttributes.removeAll(keepingCapacity: false)
        contentSize = CGSize.zero
        
        if let collectionView = collectionView,
            let dataSource = collectionView.dataSource,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            let sections = dataSource.numberOfSections?(in: collectionView) ?? 0
            var origin = CGPoint()
            
            for section in 0 ..< sections {
                var sectionAttributes = [UICollectionViewLayoutAttributes]()
                let items = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                let indexPaths = (0 ..< items).map { IndexPath(item: $0, section: section) }
                
                for indexPath in indexPaths {
                    let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? CGSize.zero
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = CGRect(origin: origin, size: size)
                    
                    sectionAttributes.append(attributes)
                    origin.y = attributes.frame.maxY
                }
                
                layoutAttributes.append(sectionAttributes)
            }
            
            contentSize = CGSize(width: collectionView.frame.width, height: origin.y)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        invalidatedLayoutAttributes = layoutAttributes
        super.invalidateLayout()
    }
    
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.reduce([], +)
            .filter { rect.intersects($0.frame) }
    }
    
    private func layoutAttributesForItemAtIndexPath(indexPath: IndexPath, allAttributes: [[UICollectionViewLayoutAttributes]]) -> UICollectionViewLayoutAttributes? {
        guard allAttributes.count > indexPath.section && allAttributes[indexPath.section].count > indexPath.item else {
            return nil
        }
        
        return allAttributes[indexPath.section][indexPath.item]
    }
    
    private func invalidatedLayoutAttributesForItemAtIndexPath(indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let invalidatedLayoutAttributes = invalidatedLayoutAttributes else {
            return nil
        }
        
        return layoutAttributesForItemAtIndexPath(indexPath: indexPath, allAttributes: invalidatedLayoutAttributes)
    }
    
    func layoutAttributesForItemAtIndexPath(indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(indexPath: indexPath, allAttributes: layoutAttributes)
    }
    
    func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return invalidatedLayoutAttributesForItemAtIndexPath(indexPath: itemIndexPath) ?? layoutAttributesForItem(at: itemIndexPath)
    }
    
    func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    
}


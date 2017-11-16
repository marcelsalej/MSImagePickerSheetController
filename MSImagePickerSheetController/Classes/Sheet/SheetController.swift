//
//  SheetController.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//


import UIKit

let sheetInset: CGFloat = 10

class SheetController: NSObject {
    
    private(set) lazy var sheetCollectionView: UICollectionView = {
        let layout = SheetCollectionViewLayout()
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = "ImagePickerSheet"
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.register(SheetPreviewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(SheetPreviewCollectionViewCell.self))
        collectionView.register(SheetActionCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(SheetActionCollectionViewCell.self))
        
        return collectionView
    }()
    
    var previewCollectionView: PreviewCollectionView
    
    private(set) var actions = [ImagePickerAction]()
    
    var actionHandlingCallback: (() -> ())?
    
    private(set) var previewHeight: CGFloat = 0
    var numberOfSelectedImages = 0
    
    var preferredSheetHeight: CGFloat {
        return allIndexPaths().map { self.sizeForSheetItemAtIndexPath(indexPath: $0).height }
            .reduce(0, +)
    }
    
    // MARK: - Initialization
    
    init(previewCollectionView: PreviewCollectionView) {
        self.previewCollectionView = previewCollectionView
        super.init()
    }
    
    
    // MARK: - Data Source
    // These methods are necessary so that no call cycles happen when calculating some design attributes
    
     func numberOfSections() -> Int {
        return 2
    }
    
     func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return actions.count
    }
    
    func allIndexPaths() -> [IndexPath] {
        let s = numberOfSections()
        return (0 ..< s).map { (section: Int) -> (Int, Int) in (self.numberOfItemsInSection(section: section), section) }
            .flatMap { (numberOfItems: Int, section: Int) -> [IndexPath] in
                (0 ..< numberOfItems).map { (item: Int) -> IndexPath in IndexPath(item: item, section: section) }
        }
    }
    
    func sizeForSheetItemAtIndexPath(indexPath: IndexPath) -> CGSize {
        let height: CGFloat = {
            if indexPath.section == 0 {
                return previewHeight
            }
            
            let actionItemHeight: CGFloat = 57
            
            let insets = attributesForItemAtIndexPath(indexPath: indexPath).backgroundInsets
            return actionItemHeight + insets.top + insets.bottom
        }()
        
        return CGSize(width: sheetCollectionView.bounds.width, height: height)
    }
    
    // MARK: - Design
    
    func attributesForItemAtIndexPath(indexPath: IndexPath) -> (corners: RoundedCorner, backgroundInsets: UIEdgeInsets) {
        let cornerRadius: CGFloat = 13
        let innerInset: CGFloat = 4
        var indexPaths = allIndexPaths()
        
        guard indexPaths.first != indexPath else {
            return (.Top(cornerRadius), UIEdgeInsets(top: 0, left: sheetInset, bottom: 0, right: sheetInset))
        }
        
        let cancelIndexPath = actions.index { $0.style == ImagePickerActionStyle.Cancel }
            .map { IndexPath(item: $0, section: 1) }
        
        
        if let cancelIndexPath = cancelIndexPath {
            if cancelIndexPath == indexPath {
                return (.All(cornerRadius), UIEdgeInsets(top: innerInset, left: sheetInset, bottom: sheetInset, right: sheetInset))
            }
            
            indexPaths.removeLast()
            
            if indexPath == indexPaths.last {
                return (.Bottom(cornerRadius), UIEdgeInsets(top: 0, left: sheetInset, bottom: innerInset, right: sheetInset))
            }
        }
        else if indexPath == indexPaths.last {
            return (.Bottom(cornerRadius), UIEdgeInsets(top: 0, left: sheetInset, bottom: sheetInset, right: sheetInset))
        }
        
        return (.None, UIEdgeInsets(top: 0, left: sheetInset, bottom: 0, right: sheetInset))
    }
    
    func fontForAction(action: ImagePickerAction) -> UIFont {
        if action.style == .Cancel {
            return UIFont.boldSystemFont(ofSize: 21)
        }
        return UIFont.systemFont(ofSize: 21)
    }
    
    // MARK: - Actions
    
    func reloadActionItems() {
        sheetCollectionView.reloadData()
    }
    
    func addAction(action: ImagePickerAction) {
        if action.style == .Cancel {
            actions = actions.filter { $0.style != .Cancel }
        }
        
        actions.append(action)
        
        if let index = actions.index(where: { $0.style == .Cancel }) {
            let cancelAction = actions.remove(at: index)
            actions.append(cancelAction)
        }
        
        reloadActionItems()
    }
    
    func removeAllActions() {
        actions = []
        reloadActionItems()
    }
    
    func handleAction(action: ImagePickerAction) {
        actionHandlingCallback?()
        action.handle(numberOfImages: numberOfSelectedImages)
    }
    
    @objc func handleCancelAction() {
        let cancelAction = actions.filter { $0.style == .Cancel }
            .first
        
        if let cancelAction = cancelAction {
            handleAction(action: cancelAction)
        }
        else {
            actionHandlingCallback?()
        }
    }
    
    // MARK: -
    
    func setPreviewHeight(height: CGFloat, invalidateLayout: Bool) {
        previewHeight = height
        if invalidateLayout {
            sheetCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}

extension SheetController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SheetCollectionViewCell
        if indexPath.section == 0 {
            let previewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(SheetPreviewCollectionViewCell.self), for: indexPath) as! SheetPreviewCollectionViewCell
            previewCell.collectionView = previewCollectionView
            
            cell = previewCell
        }
        else {
            let action = actions[indexPath.item]
            let actionCell = collectionView.dequeueReusableCell(withReuseIdentifier:NSStringFromClass(SheetActionCollectionViewCell.self), for: indexPath) as! SheetActionCollectionViewCell
            actionCell.textLabel.font = fontForAction(action: action)
            actionCell.textLabel.text = numberOfSelectedImages > 0 ? action.secondaryTitle(numberOfSelectedImages) : action.title
            
            cell = actionCell
        }
        
        cell.separatorVisible = (indexPath.section == 1)
        
        // iOS specific design
        (cell.roundedCorners, cell.backgroundInsets) = attributesForItemAtIndexPath(indexPath: indexPath as IndexPath)
        cell.normalBackgroundColor = UIColor(white: 0.97, alpha: 1)
        cell.highlightedBackgroundColor = UIColor(white: 0.92, alpha: 1)
        cell.separatorColor = UIColor(white: 0.84, alpha: 1)
        
        return cell
    }
    
    
}

extension SheetController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        handleAction(action: actions[indexPath.item])
    }
    
}

extension SheetController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForSheetItemAtIndexPath(indexPath: indexPath as IndexPath)
    }
    
}


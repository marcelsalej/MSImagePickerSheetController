//
//  SheetActionCollectionViewCell.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//
//

import UIKit

private var KVOContext = 0

class SheetActionCollectionViewCell: SheetCollectionViewCell {
    
    lazy private(set) var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.tintColor
        label.textAlignment = .center
        
        self.addSubview(label)
        
        return label
    }()
    
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
        textLabel.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions(rawValue: 0), context: &KVOContext)
    }
    
    deinit {
        textLabel.removeObserver(self, forKeyPath: "text")
    }
    
    // MARK: - Accessibility
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &KVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        accessibilityLabel = textLabel.text
    }
    
    
    // MARK: -
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        textLabel.textColor = tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = UIEdgeInsetsInsetRect(bounds, backgroundInsets)
    }
    
}


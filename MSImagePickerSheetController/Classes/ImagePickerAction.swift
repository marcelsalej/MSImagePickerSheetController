//
//  ImagePickerAction.swift
//  MSImagePickerSheetController
//
//  Created by Marcel Salej on 15/11/2017.
//

import Foundation

public enum ImagePickerActionStyle {
    case Default
    case Cancel
}

public class ImagePickerAction {
    
    public typealias Title = (Int) -> String
    public typealias Handler = (ImagePickerAction) -> ()
    public typealias SecondaryHandler = (ImagePickerAction, Int) -> ()
    
    /// The title of the action's button.
    public let title: String
    
    /// The title of the action's button when more than one image is selected.
    public let secondaryTitle: Title
    
    /// The style of the action. This is used to call a cancel handler when dismissing the controller by tapping the background.
    public let style: ImagePickerActionStyle
    
    private let handler: Handler?
    private let secondaryHandler: SecondaryHandler?
    
    /// Initializes a new cancel ImagePickerAction
    public init(cancelTitle: String) {
        self.title = cancelTitle
        self.secondaryTitle = { _ in cancelTitle }
        self.style = .Cancel
        self.handler = nil
        self.secondaryHandler = nil
    }
    
    /// Initializes a new ImagePickerAction. The secondary title and handler are used when at least 1 image has been selected.
    /// Secondary title defaults to title if not specified.
    /// Secondary handler defaults to handler if not specified.
    public convenience init(title: String, secondaryTitle: String? = nil, style: ImagePickerActionStyle = .Default, handler: @escaping Handler, secondaryHandler: SecondaryHandler? = nil) {
        self.init(title: title, secondaryTitle: secondaryTitle.map { string in { _ in string }}, style: style, handler: handler, secondaryHandlerOrNil: secondaryHandler)
    }
    
    /// Initializes a new ImagePickerAction. The secondary title and handler are used when at least 1 image has been selected.
    /// Secondary title defaults to title if not specified. Use the closure to format a title according to the selection.
    /// Secondary handler defaults to handler if not specified
    public init(title: String, secondaryTitle: Title?, style: ImagePickerActionStyle = .Default, handler: @escaping Handler, secondaryHandlerOrNil: SecondaryHandler? = nil) {
        var secondaryHandler = secondaryHandlerOrNil
        if secondaryHandler == nil {
            secondaryHandler = { action, _ in
                handler(action)
            }
        }
        
        self.title = title
        self.secondaryTitle = secondaryTitle ?? { _ in title }
        self.style = style
        self.handler = handler
        self.secondaryHandler = secondaryHandler
    }
    
    func handle(numberOfImages: Int = 0) {
        if numberOfImages > 0 {
            secondaryHandler?(self, numberOfImages)
        }
        else {
            handler?(self)
        }
    }
    
}

func ?? (left: ImagePickerAction.Title?, right: @escaping ImagePickerAction.Title) -> ImagePickerAction.Title {
    if let left = left {
        return left
    }
    
    return right
}


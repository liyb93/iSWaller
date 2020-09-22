//
//  iSTextField.swift
//  iSWaller
//
//  Created by liyb on 2020/7/27.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSTextField: NSTextField {

    var textDidChangeHandler:((String)->())?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        cell = iSTextFieldCell.init()
    }
    
    init() {
        super.init(frame: .zero)
        cell = iSTextFieldCell.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        cell = iSTextFieldCell.init()
    }
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        textDidChangeHandler?(stringValue)
    }
    
}

class iSTextFieldCell: NSTextFieldCell {
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        var newRect:NSRect = super.drawingRect(forBounds: theRect)
        let textSize:NSSize = self.cellSize(forBounds: theRect)
        let heightDelta:CGFloat = newRect.size.height - textSize.height
        if heightDelta > 0 {
            newRect.size.height = textSize.height
            newRect.origin.y += heightDelta * 0.5
        }
        return newRect
    }
}

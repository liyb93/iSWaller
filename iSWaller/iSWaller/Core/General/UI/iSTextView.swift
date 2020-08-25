//
//  iSTextView.swift
//  iSWaller
//
//  Created by liyb on 2020/7/4.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSTextView: NSTextView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeWhenFirstResponder, .inVisibleRect, .activeInActiveApp]
        let area = NSTrackingArea.init(rect: frame, options: options, owner: self, userInfo: nil)
        addTrackingArea(area)
        becomeFirstResponder()
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        let point = convert(event.locationInWindow, from: nil)
        if self.isMousePoint(point, in: frame) {
            isSelectable = false
            NSCursor.arrow.set()
        } else {
            isSelectable = true
            isEditable = true
        }
    }
    
}

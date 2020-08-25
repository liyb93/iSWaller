//
//  NSButton+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/7/1.
//  Copyright © 2020 liyb. All rights reserved.
//

import AppKit

extension NSButton {
    func setTitle(_ title: String) {
        self.title = title
        bezelStyle = .recessed
        isBordered = false
        image = nil
        setButtonType(.momentaryLight)
    }
    
    func setImage(_ image: NSImage?, state: NSControl.StateValue = .off) {
        self.image = image
        self.state = state
        self.title = ""
        setButtonType(.radio)
    }
}

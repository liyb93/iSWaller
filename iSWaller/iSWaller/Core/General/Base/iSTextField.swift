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
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        textDidChangeHandler?(stringValue)
    }
}

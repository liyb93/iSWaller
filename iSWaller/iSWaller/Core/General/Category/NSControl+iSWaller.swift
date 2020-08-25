//
//  NSControl+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/7/1.
//  Copyright © 2020 liyb. All rights reserved.
//

import AppKit

extension NSControl {
    func addTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }
}

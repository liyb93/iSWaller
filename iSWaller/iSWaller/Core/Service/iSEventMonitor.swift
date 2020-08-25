//
//  iSEventMonitor.swift
//  iSWaller
//
//  Created by liyb on 2020/6/8.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSEventMonitor: NSObject {
    private var mask: NSEvent.EventTypeMask!
    private var handler: ((NSEvent)->(Void))!
    private var monitor: Any?
    
    init(_ mask: NSEvent.EventTypeMask, _ handler: @escaping ((NSEvent?)->(Void))) {
        super.init()
        self.mask = mask
        self.handler = handler
    }
    
    func start() {
        self.monitor = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler: self.handler)
    }
    
    func stop() {
        if let m = self.monitor {
            NSEvent.removeMonitor(m)
            self.monitor = nil
        }
    }
}

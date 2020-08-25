//
//  AppDelegate.swift
//  iSWaller_Helper
//
//  Created by liyb on 2020/7/5.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 启动主程序
        var compoents = (Bundle.main.bundlePath as NSString).pathComponents
        if compoents.count > 4 {
            compoents = (compoents as NSArray).subarray(with: NSRange.init(location: 0, length: compoents.count-4)) as? [String] ?? []
            let path = NSString.path(withComponents: compoents)
            NSWorkspace.shared.launchApplication(path)
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}


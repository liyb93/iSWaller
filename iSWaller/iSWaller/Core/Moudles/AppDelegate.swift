//
//  AppDelegate.swift
//  iSWaller
//
//  Created by liyb on 2020/6/8.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var statusItem: NSStatusItem = {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        return item
    }()
    
    private lazy var popover: NSPopover = {
        let p = NSPopover.init()
        p.appearance = NSAppearance.init(named: .darkAqua)
        p.contentViewController = iSRootController.init()
        p.behavior = .applicationDefined
        return p
    }()
    
    private var monitor: iSEventMonitor!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        configStatusBar()
        // 配置快捷键
        iSDataManager.shared.configHotKey()
        // 自动更换
        iSDataManager.shared.startAutoChangeWallpaper()
        monitor = iSEventMonitor.init([.leftMouseDown, .rightMouseDown]) { [unowned self] (event) -> (Void) in
            if self.popover.isShown {
                self.popover.performClose(event)
            }
        }
    }

    private func configStatusBar() {
        let icon = NSImage.init(named: "statusBar")
        icon?.isTemplate = true
        if #available(macOS 10.14, *) {
            statusItem.button?.image = icon
        } else {
            statusItem.image = icon
        }
        statusItem.button?.target = self
        statusItem.button?.action = #selector(openMainMenu(_:))
    }
    
    @objc private func openMainMenu(_ button: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(button)
            monitor.stop()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
            monitor.start()
            popover.contentViewController?.becomeFirstResponder()
        }
    }
}


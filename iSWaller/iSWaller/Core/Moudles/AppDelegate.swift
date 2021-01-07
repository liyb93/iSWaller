//
//  AppDelegate.swift
//  iSWaller
//
//  Created by liyb on 2020/6/8.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

fileprivate let iSStartUpTag = 1993

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
    
    private lazy var menu: NSMenu = {
        let menu = NSMenu.init(title: "菜单")
        let next = NSMenuItem.init(title: NSLocalizedString("iSSettingNext", comment: "下一张"), action: #selector(nextWallpaper), keyEquivalent: "")
        let before = NSMenuItem.init(title: NSLocalizedString("iSSettingPrevious", comment: "上一张"), action: #selector(beforeWallpaper), keyEquivalent: "")
        let start = NSMenuItem.init(title: NSLocalizedString("iSSettingStartup", comment: "开机自启"), action: #selector(startLoad(_:)), keyEquivalent: "")
        start.tag = iSStartUpTag
        let exit = NSMenuItem.init(title: NSLocalizedString("iSStatusExit", comment: "退出"), action: #selector(exitApp), keyEquivalent: "")
        menu.addItem(next)
        menu.addItem(before)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(start)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(exit)
        menu.delegate = self
        return menu
    }()
    
    private var monitor: iSEventMonitor!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 配置状态栏
        configStatusBar()
        // 配置菜单
        configMenu()
        // 配置快捷键
        iSDataManager.shared.configHotKey()
        // 自动更换
        iSDataManager.shared.startAutoChangeWallpaper()
        monitor = iSEventMonitor.init([.leftMouseDown, .rightMouseDown]) { [unowned self] (event) -> (Void) in
            if self.popover.isShown {
                self.popover.performClose(event)
                self.statusItem.menu = self.menu
            }
        }
        
        // 注册开机自启通知
        NotificationCenter.default.addObserver(self, selector: #selector(configMenu), name: iSStartUpNotification, object: nil)
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
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseDown])
    }
    
    @objc private func configMenu() {
        if let item = menu.items.filter({$0.tag == iSStartUpTag}).first {
            item.state = iSDataManager.shared.isStartUp ? .on : .off
        }
    }
    
    @objc private func openMainMenu(_ button: NSStatusBarButton) {
        if let event = NSApp.currentEvent {
            switch event.type {
            case .leftMouseDown:
                if popover.isShown {
                    popover.performClose(button)
                    monitor.stop()
                    statusItem.menu = menu
                } else {
                    menu.cancelTracking()
                    statusItem.menu = nil
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
                    monitor.start()
                    popover.contentViewController?.becomeFirstResponder()
                }
            default:
                break
            }
        }
    }
    
    @objc private func nextWallpaper() {
        iSDataManager.shared.nextWallpaper()
    }
    
    @objc private func beforeWallpaper() {
        iSDataManager.shared.previousWallpaper()
    }
    
    @objc private func startLoad(_ item: NSMenuItem) {
        if item.state == .off {
            item.state = .on
            iSDataManager.shared.isStartUp = true
        } else {
            item.state = .off
            iSDataManager.shared.isStartUp = false
        }
        // 发送开机自启通知
        NotificationCenter.default.post(name: iSStartUpNotification, object: nil)
    }
    
    @objc private func exitApp() {
        NSApp.terminate(nil)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if let button = statusItem.button {
            openMainMenu(button)
        }
    }
}

//
//  iSSettingController.swift
//  iSWaller
//
//  Created by liyb on 2020/6/30.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa
import MASShortcut

protocol iSSettingControllerDelegate: NSObjectProtocol {
    func settingController(_ controller: iSSettingController, type: iSChidrenControllerType)
}

class iSSettingController: iSBaseController {

    @IBOutlet weak var navigationBar: iSNavigationBar!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var aboutButton: NSButton!
    @IBOutlet weak var horizontalLineView: NSView!
    
    var delegate: iSSettingControllerDelegate?
    
    private var dataSource: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configData()
        
        // 注册开机自启通知
        NotificationCenter.default.addObserver(self, selector: #selector(configData), name: iSStartUpNotification, object: nil)
    }
    
    private func configUI() {
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(iSSettingSelectedItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.selected"))
        collectionView.register(iSSettingChooseItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.choose"))
        collectionView.register(iSSettingChangeItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.change"))
        collectionView.register(iSSettingConfigItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.config"))
        collectionView.register(iSSettingActionItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.action"))
        navigationBar.backButton.addTarget(self, action: #selector(backDidClickAction(_:)))
        navigationBar.titleLabel.stringValue = NSLocalizedString("iSSettingTitle", comment: "设置")
        navigationBar.rightButton.setImage(NSImage.init(named: "nav_exit"))
        navigationBar.rightButton.addTarget(self, action: #selector(exitDidClickAction(_:)))
        aboutButton.setTitle(NSLocalizedString("iSSettingAbout", comment: "关于我们"))
        horizontalLineView.setBackgroundColor(NSColor.separator)
    }
    
    @objc private func configData() {
        let start: [String: Any] = ["title": NSLocalizedString("iSSettingStartup", comment: "开机自启"), "select": iSDataManager.shared.isStartUp]
        let unite: [String: Any] = ["title": NSLocalizedString("iSSettingUnite", comment: "多屏统一"), "select": iSDataManager.shared.isUnite]
        let notification: [String: Any] = ["title": NSLocalizedString("iSSettingNotification", comment: "更换壁纸通知"), "select": iSDataManager.shared.isNotification]
        let time: [String: Any] = ["title": NSLocalizedString("iSSettingAutoChange", comment: "自动切换(本地)"), "select": iSDataManager.shared.autoChangeWallpaperType.rawValue, "items": iSAutoChangeTimes]
        let quality: [String: Any] = ["title": NSLocalizedString("iSSettingPreview", comment: "预览质量"), "select": iSDataManager.shared.imageQuality.rawValue, "items": iSImageQualitys]
        let path: [String: Any] = ["title": NSLocalizedString("iSSettingSavePath", comment: "存储路径"), "select": iSDataManager.shared.wallpaperPath]
        var config: [String: Any] = ["title": NSLocalizedString("iSSettingHotKey", comment: "快捷键")]
        if let previous = iSDataManager.shared.previousShortcut {
            config["previous"] = previous
        }
        if let next = iSDataManager.shared.nextShortcut {
            config["next"] = next
        }
        let cache: [String: Any] = ["title": NSLocalizedString("iSSettingCleanCache", comment: "清除缓存")]
        dataSource = [start, unite, notification, time, quality, path, config, cache]
        collectionView.reloadData()
    }
    
    // MARK: < Action >
    @IBAction func aboutDidClickAction(_ sender: Any) {
        delegate?.settingController(self, type: .about)
    }
    
    @objc private func backDidClickAction(_ sender: Any) {
        navigationDelegate?.navigationController(self, didClickBackButtonAt: .setting)
    }
    
    @objc private func exitDidClickAction(_ sender: Any) {
        NSApp.terminate(nil)
    }
}

extension iSSettingController: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let data = dataSource[indexPath.item]
        if indexPath.item <= 2 {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier.init("is.liyb.selected"), for: indexPath) as! iSSettingSelectedItem
            item.data = data
            item.delegate = self
            return item
        } else if indexPath.item <= 4 {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier.init("is.liyb.choose"), for: indexPath) as! iSSettingChooseItem
            item.data = data
            item.delegate = self
            return item
        } else if indexPath.item == 5 {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier.init("is.liyb.change"), for: indexPath) as! iSSettingChangeItem
            item.data = data
            item.delegate = self
            return item
        } else if indexPath.item == 6 {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier.init("is.liyb.config"), for: indexPath) as! iSSettingConfigItem
            item.data = data
            item.delegate = self
            return item
        } else {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier.init("is.liyb.action"), for: indexPath) as! iSSettingActionItem
            item.data = data
            item.delegate = self
            return item
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = collectionView.frame.width
        if indexPath.item <= 2 {
            return CGSize.init(width: width, height: 35)
        } else if indexPath.item <= 4 {
            return CGSize.init(width: width, height: 65)
        } else if indexPath.item == 5 {
            return CGSize.init(width: width, height: 65)
        } else if indexPath.item == 6 {
            return CGSize.init(width: width, height: 95)
        } else {
            return CGSize.init(width: width, height: 50)
        }
    }
}

extension iSSettingController: iSSettingSelectedItemDelegate, iSSettingChooseItemDelegate, iSSettingChangeItemDelegate, iSSettingConfigItemDelegate, iSSettingActionItemDelegate {
    func settingSelectedItem(_ item: iSSettingSelectedItem, didSelectItemAt state: NSControl.StateValue) {
        if let indexPath = collectionView.indexPath(for: item) {
            var result: Bool = false
            if state == .on {
                result = true
            }
            if indexPath.item == 0 {
                iSDataManager.shared.isStartUp = result
                // 发送开机自启通知
                NotificationCenter.default.post(name: iSStartUpNotification, object: nil)
            } else if indexPath.item == 1 {
                iSDataManager.shared.isUnite = result
            } else {
                iSDataManager.shared.isNotification = result
            }
        }
    }
    
    func settingChooseItem(_ item: iSSettingChooseItem, didSelectItemAt value: Int) {
        if let indexPath = collectionView.indexPath(for: item) {
            if indexPath.item == 3 {
                if iSDataManager.shared.autoChangeWallpaperType.rawValue != value {
                    iSDataManager.shared.autoChangeWallpaperType = iSAutoChnageWallperType.init(rawValue: value) ?? .off
                }
            } else if indexPath.item == 4 {
                if iSDataManager.shared.imageQuality.rawValue != value {
                    iSDataManager.shared.imageQuality = iSImageQualityType.init(rawValue: value) ?? .medium
                    // 更新图片预览质量通知
                    NotificationCenter.default.post(name: iSUpdateImageQualityNotification, object: nil)
                }
            }
        }
    }
    
    func settingChangeItem(_ item: iSSettingChangeItem, didClickChangePath handler: ((String) -> ())?) {
        let panel = NSOpenPanel.init()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        if let window = NSApplication.shared.windows.first {
            panel.beginSheetModal(for: window) { (response) in
                if response == .OK, let url = panel.url {
                    handler?(url.path)
                    // 获取旧目录
                    let oldPath = iSDataManager.shared.wallpaperPath
                    // 更新目录
                    iSDataManager.shared.wallpaperPath = url.path
                    // 移动壁纸
                    iSDataManager.shared.wallpaperMove(oldPath, toPath: url.path)
                } else {
                    iSLog(response.rawValue)
                }
            }
        } else {
            panel.begin { (response) in
                if response == .OK, let url = panel.url {
                    handler?(url.path)
                    // 获取旧目录
                    let oldPath = iSDataManager.shared.wallpaperPath
                    // 更新目录
                    iSDataManager.shared.wallpaperPath = url.path
                    // 移动壁纸
                    iSDataManager.shared.wallpaperMove(oldPath, toPath: url.path)
                }
            }
        }
    }
    
    func settingConfigItem(_ item: iSSettingConfigItem, didPreviousChangeAt shortcut: MASShortcut?) {
        if let value = shortcut {
            let keycode = value.keyCode
            let modifier = value.modifierFlags
            iSDataManager.shared.setHotKey(keycode, modifier: modifier, type: .previous)
            MASShortcutMonitor.shared()?.register(value, withAction: {
               iSDataManager.shared.previousWallpaper()
            })
        }
    }
    
    func settingConfigItem(_ item: iSSettingConfigItem, didNextChangeAt shortcut: MASShortcut?) {
        if let value = shortcut {
            let keycode = value.keyCode
            let modifier = value.modifierFlags
            iSDataManager.shared.setHotKey(keycode, modifier: modifier, type: .next)
            MASShortcutMonitor.shared()?.register(value, withAction: {
                iSDataManager.shared.nextWallpaper()
            })
        }
    }
    
    func settingActionItem(didClick item: iSSettingActionItem) {
        iSHUDManager.show(to: view, text: NSLocalizedString("iSSettingCleaning", comment: "清理中..."), delay: 2)
        iSDataManager.shared.clearNetworkCache()
        // 清理缓存通知
        NotificationCenter.default.post(name: iSCleanCacheNotification, object: nil)
    }
}

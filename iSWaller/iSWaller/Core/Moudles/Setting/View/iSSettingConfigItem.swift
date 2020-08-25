//
//  iSSettingConfigItem.swift
//  iSWaller
//
//  Created by liyb on 2020/7/15.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa
import MASShortcut

protocol iSSettingConfigItemDelegate: NSObjectProtocol {
    func settingConfigItem(_ item: iSSettingConfigItem, didPreviousChangeAt shortcut: MASShortcut?)
    func settingConfigItem(_ item: iSSettingConfigItem, didNextChangeAt shortcut: MASShortcut?)
}

class iSSettingConfigItem: NSCollectionViewItem {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var previousView: MASShortcutView!
    @IBOutlet weak var nextView: MASShortcutView!
    @IBOutlet weak var previousLabel: NSTextField!
    @IBOutlet weak var nextLabel: NSTextField!
    
    var data: [String: Any]? {
        didSet {
            if let title = data?["title"] as? String {
                titleLabel.stringValue = title
                if let previous = data?["previous"] as? MASShortcut {
                    previousView.shortcutValue = previous
                }
                if let next = data?["next"] as? MASShortcut {
                    nextView.shortcutValue = next
                }
            }
        }
    }
    
    weak var delegate: iSSettingConfigItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previousLabel.stringValue = NSLocalizedString("iSSettingPrevious", comment: "上一张")
        nextLabel.stringValue = NSLocalizedString("iSSettingNext", comment: "下一张")
        
        // 监听快捷键变化
        previousView.shortcutValueChange = { [unowned self] (shortcutView) in
            self.delegate?.settingConfigItem(self, didPreviousChangeAt: shortcutView?.shortcutValue)
        }
        nextView.shortcutValueChange = { [unowned self] (shortcutView) in
            self.delegate?.settingConfigItem(self, didNextChangeAt: shortcutView?.shortcutValue)
        }
    }
    
}

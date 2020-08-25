//
//  iSSettingChangeItem.swift
//  iSWaller
//
//  Created by liyb on 2020/7/15.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSSettingChangeItemDelegate: NSObjectProtocol {
    func settingChangeItem(_ item: iSSettingChangeItem, didClickChangePath handler:((String)->())?)
}

class iSSettingChangeItem: NSCollectionViewItem {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var textLabel: NSTextField!
    @IBOutlet weak var changeButton: NSButton!
    
    var data: [String: Any]? {
        didSet {
            if let title = data?["title"] as? String, let item = data?["select"] as? String {
                titleLabel.stringValue = title
                textLabel.stringValue = item
            }
        }
    }
    
    weak var delegate: iSSettingChangeItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.isEditable = false
        changeButton.title = NSLocalizedString("iSSettingChange", comment: "更改")
    }
    
    @IBAction func changeDidClickAction(_ sender: Any) {
        delegate?.settingChangeItem(self, didClickChangePath: { [unowned self] (path) in
            self.textLabel.stringValue = path
        })
    }
}

//
//  iSSettingChooseItem.swift
//  iSWaller
//
//  Created by liyb on 2020/7/15.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSSettingChooseItemDelegate: NSObjectProtocol {
    func settingChooseItem(_ item: iSSettingChooseItem, didSelectItemAt value: Int)
}

class iSSettingChooseItem: NSCollectionViewItem {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    
    var data: [String: Any]? {
        didSet {
            if let title = data?["title"] as? String, let item = data?["select"] as? Int, let items = data?["items"] as? [String] {
                titleLabel.stringValue = title
                if popUpButton.itemTitles != items {
                    popUpButton.removeAllItems()
                    popUpButton.addItems(withTitles: items)
                }
                popUpButton.selectItem(at: item)
            }
        }
    }
    
    weak var delegate: iSSettingChooseItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func chooseDidClickAction(_ sender: NSPopUpButton) {
        delegate?.settingChooseItem(self, didSelectItemAt: sender.indexOfSelectedItem)
    }
}

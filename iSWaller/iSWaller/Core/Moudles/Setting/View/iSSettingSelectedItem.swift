//
//  iSSettingSelectedItem.swift
//  iSWaller
//
//  Created by liyb on 2020/7/15.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSSettingSelectedItemDelegate: NSObjectProtocol {
    func settingSelectedItem(_ item: iSSettingSelectedItem, didSelectItemAt state: NSButton.StateValue)
}

class iSSettingSelectedItem: NSCollectionViewItem {

    @IBOutlet weak var selectedButton: NSButton!
    
    var data: [String: Any]? {
        didSet {
            if let title = data?["title"] as? String, let select = data?["select"] as? Bool {
                selectedButton.title = title
                if select {
                    selectedButton.state = .on
                } else {
                    selectedButton.state = .off
                }
            }
        }
    }
    
    weak var delegate: iSSettingSelectedItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func selectDidClickAction(_ sender: NSButton) {
        delegate?.settingSelectedItem(self, didSelectItemAt: sender.state)
    }
}

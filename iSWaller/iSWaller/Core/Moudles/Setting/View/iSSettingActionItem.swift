//
//  iSSettingActionItem.swift
//  iSWaller
//
//  Created by liyb on 2020/7/15.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSSettingActionItemDelegate: NSObjectProtocol {
    func settingActionItem(didClick item: iSSettingActionItem)
}

class iSSettingActionItem: NSCollectionViewItem {

    @IBOutlet weak var textLabel: NSTextField!
    
    var data: [String: Any]? {
        didSet {
            if let title = data?["title"] as? String {
                textLabel.stringValue = title
            }
        }
    }
    
    weak var delegate: iSSettingActionItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didSelectAction(_ sender: Any) {
        delegate?.settingActionItem(didClick: self)
    }
}

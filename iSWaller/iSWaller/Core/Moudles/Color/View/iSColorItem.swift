//
//  iSColorItem.swift
//  iSWaller
//
//  Created by liyb on 2020/9/10.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSColorItemDelegate: NSObjectProtocol {
    func colorItem(didSelect item: iSColorItem)
}

class iSColorItem: NSCollectionViewItem {

    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    weak var delegate: iSColorItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        delegate?.colorItem(didSelect: self)
    }
}

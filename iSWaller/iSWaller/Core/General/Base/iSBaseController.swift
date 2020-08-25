//
//  iSBaseController.swift
//  iSWaller
//
//  Created by liyb on 2020/7/1.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSBaseController: NSViewController {

    weak var navigationDelegate: iSNavigationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBackgroundColor(NSColor.backgroundColor)
    }
    
}

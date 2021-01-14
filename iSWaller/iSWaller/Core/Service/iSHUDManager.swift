//
//  iSHUDManager.swift
//  iSWaller
//
//  Created by liyb on 2020/7/3.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa
import LYBProgressHUD

class iSHUDManager: NSObject {
    class func show(to view: NSView) {
//        MBProgressHUD.showAdded(to: view, animated: true)
        LYBProgressHUD.show(in: view)
    }
    
    class func hide(to view: NSView) {
//        MBProgressHUD.hide(for: view, animated: true)
        LYBProgressHUD.dismiss(in: view)
    }
    
    class func show(to view: NSView, text: String, delay: TimeInterval) {
//        let hud = MBProgressHUD.showAdded(to: view, animated: true)
//        hud?.mode = MBProgressHUDModeText
//        hud?.labelText = text
//        hud?.labelColor = .separator
//        hud?.margin = 10.0
//        hud?.removeFromSuperViewOnHide = true
//        hud?.hide(true, afterDelay: delay)
        LYBProgressHUD.show(in: view, message: text, style: .text)
        LYBProgressHUD.dismiss(in: view, after: delay)
    }
}

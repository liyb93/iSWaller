//
//  iSNavigationControllerDelegate.swift
//  iSWaller
//
//  Created by liyb on 2020/7/1.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

enum iSChidrenControllerType: Int {
    case home = 0   // 首页
    case search = 1 // 搜索
    case download = 2   // 下载
    case setting = 3    // 设置
    case about = 4  // 关于我们
    case feedback = 5 // 赏赐
}

protocol iSNavigationControllerDelegate: NSObjectProtocol {
    func navigationController(_ controller:iSBaseController, didClickBackButtonAt type:iSChidrenControllerType)
}

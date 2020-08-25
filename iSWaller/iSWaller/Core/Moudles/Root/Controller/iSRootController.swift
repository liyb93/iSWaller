//
//  iSRootController.swift
//  iSWaller
//
//  Created by liyb on 2020/6/30.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSRootController: NSViewController {

    @IBOutlet weak var containView: NSView!
    
    private lazy var home: iSGalleryController = {
        let controller = iSGalleryController.init()
        controller.delegate = self
        return controller
    }()
    
    private lazy var search: iSSearchController = {
        let controller = iSSearchController.init()
        controller.navigationDelegate = self
        return controller
    }()
    
    private lazy var download: iSDownloadController = {
        let controller = iSDownloadController.init()
        controller.navigationDelegate = self
        return controller
    }()
    
    private lazy var setting: iSSettingController = {
        let controller = iSSettingController.init()
        controller.navigationDelegate = self
        controller.delegate = self
        return controller
    }()
    
    private lazy var about: iSAboutController = {
        let controller = iSAboutController.init()
        controller.navigationDelegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubControllers()
    }
    
    private func configSubControllers() {
        addChild(home)
        addChild(search)
        addChild(download)
        addChild(setting)
        addChild(about)
        
        let firstView = children[0].view
        containView.addSubview(firstView)
    }
}

extension iSRootController: iSGalleryControllerDelegate, iSSettingControllerDelegate, iSNavigationControllerDelegate {
    func galleryController(_ controller: iSGalleryController, didSelectItemAt type: iSChidrenControllerType) {
        let index = type.rawValue
        let to = children[index]
        if to is iSDownloadController {
            (to as! iSDownloadController).requestData()
        }
        transition(from: controller, to: to, options: .slideLeft, completionHandler: nil)
    }
    
    func settingController(_ controller: iSSettingController, type: iSChidrenControllerType) {
        let index = type.rawValue
        let to = children[index]
        transition(from: controller, to: to, options: .slideLeft, completionHandler: nil)
    }
    
    func navigationController(_ controller: iSBaseController, didClickBackButtonAt type: iSChidrenControllerType) {
        let to = children[0]
        transition(from: controller, to: to, options: .slideRight, completionHandler: nil)
    }
}

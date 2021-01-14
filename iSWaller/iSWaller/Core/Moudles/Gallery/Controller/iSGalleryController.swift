//
//  iSGalleryController.swift
//  iSWaller
//
//  Created by liyb on 2020/6/30.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSGalleryControllerDelegate: NSObjectProtocol {
    func galleryController(_ controller: iSGalleryController, didSelectItemAt type:iSChidrenControllerType)
}

class iSGalleryController: iSBaseController {

    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var navigationBar: NSView!
    @IBOutlet weak var progressView: iSDownloadProgressView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var toolBar: NSView!
    @IBOutlet weak var historyButton: NSButton!
    @IBOutlet weak var settingButton: NSButton!
    @IBOutlet weak var categoryView: iSCategoryView!
    
    private lazy var pageController: iSPageController = {
        let controller = iSPageController.init()
        controller.delegate = self
        controller.arrangedObjects = [iSNetwork.Order.latest, iSNetwork.Order.popular]
        return controller
    }()
    
    weak var delegate: iSGalleryControllerDelegate?
    
    // MARK: < Life cycle >
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private func configUI() {
        pageController.view.frame = contentView.bounds
        contentView.addSubview(pageController.view)
        
        searchButton.setImage(NSImage.init(named: "nav_search"))
        historyButton.setImage(NSImage.init(named: "nav_download"))
        settingButton.setImage(NSImage.init(named: "nav_setting"))
        titleLabel.stringValue = iSDataManager.shared.appName ?? "iSWalleer"
        titleLabel.isEditable = false
        titleLabel.font = NSFont.boldSystemFont(ofSize: 20)
        titleLabel.isBordered = false
        titleLabel.drawsBackground = false
        titleLabel.backgroundColor = .clear
        progressView.delegate = self
        categoryView.delegate = self
        
    }
    
    // MARK: < Action >
    @IBAction func searchDidClickAction(_ sender: Any) {
        delegate?.galleryController(self, didSelectItemAt: .search)
    }
    
    @IBAction func historyDidClickAction(_ sender: Any) {
        delegate?.galleryController(self, didSelectItemAt: .download)
    }
    
    @IBAction func settingDidClickAction(_ sender: Any) {
        delegate?.galleryController(self, didSelectItemAt: .setting)
    }
}

extension iSGalleryController: NSPageControllerDelegate {
    func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
        let vc = iSImageController.init()
        vc.view.autoresizingMask = [.width, .height]
        vc.delegate = self
        return vc
    }
    
    func pageController(_ pageController: NSPageController, identifierFor object: Any) -> NSPageController.ObjectIdentifier {
        guard let order = object as? iSNetwork.Order else { return iSNetwork.Order.latest.rawValue }
        return order.rawValue
    }

    func pageController(_ pageController: NSPageController, prepare viewController: NSViewController, with object: Any?) {
        guard let item = object as? iSNetwork.Order, let vc = viewController as? iSImageController else { return }
        vc.order = item
    }
    
    func pageControllerDidEndLiveTransition(_ pageController: NSPageController) {
        categoryView.selectedIndex = pageController.selectedIndex
        pageController.completeTransition()
    }
}

extension iSGalleryController: iSImageControllerDelegate {
    func imageController(_ controller: iSImageController, didDownloadAt model: iSGalleryModel, progress: CGFloat) {
        progressView.showProgress(model, progress: progress)
    }
}

extension iSGalleryController: iSDownloadProgressViewDelegate {
    func downloadProgressView(didClickCancelButton view: iSDownloadProgressView) {
        iSNetwork.cancelDownload()
    }
}

extension iSGalleryController: iSCategoryViewDelegate {
    func categoryView(_ view: iSCategoryView, didSelectItemAt index: Int) {
        pageController.selectedIndex = index
    }
}

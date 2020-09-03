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

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var navigationBar: NSView!
    @IBOutlet weak var progressView: iSDownloadProgressView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var toolBar: NSView!
    @IBOutlet weak var historyButton: NSButton!
    @IBOutlet weak var settingButton: NSButton!
    @IBOutlet weak var refreshButton: iSRefreshButton!
    
    private var dataSource: [iSGalleryModel] = []
    private var page: Int = 1
    // 是否请求下一页
    private var isRequestNextPage: Bool = false
    
    weak var delegate: iSGalleryControllerDelegate?
    
    // MARK: < Life cycle >
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        previousPageData()
        
        // 图片质量更新通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateImageQualityAction), name: iSUpdateImageQualityNotification, object: nil)
        // 清理缓存通知
        NotificationCenter.default.addObserver(self, selector: #selector(cleanCacheAction), name: iSCleanCacheNotification, object: nil)
        // 注册滚动通知
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidScroll), name: NSScrollView.didLiveScrollNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidEndScroll), name: NSScrollView.didEndLiveScrollNotification, object: nil)
    }
    
    private func configUI() {
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(iSImageItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.image"))
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
        
        // 点击刷新
        refreshButton.didClickButtonHandler = { [unowned self] in
            self.collectionView.scroll(.zero)
            self.previousPageData()
        }
    }
    
    // MARK: < Network >
    private func previousPageData() {
        page = 1
        iSHUDManager.show(to: view)
        iSNetwork.gallery { [unowned self] (result) in
            iSHUDManager.hide(to: self.view)
            self.refreshButton.stopAnimaton()
            if let hits = result as? [String: Any], let data = hits["hits"] {
                let arr = (Array<iSGalleryModel>.deserialize(from: data as? [Any]) as? [iSGalleryModel]) ?? []
                self.dataSource.append(contentsOf: arr)
                self.collectionView.reloadData()
            } else {
                let text = NSLocalizedString("iSNetworkFailed", comment: "未请求到数据，请稍后重试")
                iSHUDManager.show(to: self.view, text: text, delay: 2)
            }
        }
    }
    
    private func nextPageData() {
        page += 1
        iSHUDManager.show(to: view)
        iSNetwork.gallery(page) { [unowned self] (result) in
            iSHUDManager.hide(to: self.view)
            if let hits = result as? [String: Any], let data = hits["hits"] {
                let arr = (Array<iSGalleryModel>.deserialize(from: data as? [Any]) as? [iSGalleryModel]) ?? []
                if arr.count <= 0 {
                    let text = NSLocalizedString("iSNoMoreData", comment: "没有更多数据了")
                    iSHUDManager.show(to: self.view, text: text, delay: 2)
                } else {
                    self.dataSource.append(contentsOf: arr)
                    self.collectionView.reloadData()
                }
            } else {
                self.page -= 1
                let text = NSLocalizedString("iSNoMoreData", comment: "没有更多数据了")
                iSHUDManager.show(to: self.view, text: text, delay: 2)
            }
        }
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
    
    @objc private func scrollViewDidScroll() {
        let offsetY = scrollView.contentView.bounds.origin.y
        let contentHeight = scrollView.documentView?.bounds.height  ?? 0
        let height = contentHeight - scrollView.contentSize.height
        if offsetY >= height {
            isRequestNextPage = true
        } else {
            isRequestNextPage = false
        }
    }
    
    @objc private func scrollViewDidEndScroll() {
        if isRequestNextPage {
            nextPageData()
        }
    }
    
    @objc private func updateImageQualityAction() {
        collectionView.reloadData()
    }
    
    @objc private func cleanCacheAction() {
        dataSource = []
        previousPageData()
    }
}

extension iSGalleryController: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.image"), for: indexPath) as! iSImageItem
        item.gallery = dataSource[indexPath.item]
        item.delegate = self
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = collectionView.frame.width
        let height = width * 0.6
        return CGSize.init(width: width, height: height)
    }
}

extension iSGalleryController: iSImageItemDelegate {
    func imageItem(_ item: iSImageItem, didClickDownloadAt model: iSGalleryModel?) {
        if let m = model {
            iSNetwork.download(m.largeImageURL, progress: { [unowned self] (progress) in
                self.progressView.showProgress(model, progress: progress)
            }) { (url) in
                if let u = url {
                    iSDataManager.shared.setDesktopImage(u, model: model)
                    let download = iSDownloadModel.init(model)
                    iSDataManager.shared.currentWallpaper = download
                    iSDataManager.shared.append(download)
                } else {
                    iSHUDManager.show(to: self.view, text: NSLocalizedString("iSDownloadError", comment: "下载失败"), delay: 2)
                }
            }
        }
    }
}

extension iSGalleryController: iSDownloadProgressViewDelegate {
    func downloadProgressView(didClickCancelButton view: iSDownloadProgressView) {
        iSNetwork.cancelDownload()
    }
}

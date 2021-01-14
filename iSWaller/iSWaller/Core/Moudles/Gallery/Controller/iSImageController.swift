//
//  File Name:  iSImageController.swift
//  Product Name:   iSWaller
//  Created Date:   2021/1/14 13:30
//

import Cocoa

protocol iSImageControllerDelegate: NSObjectProtocol {
    func imageController(_ controller: iSImageController, didDownloadAt model:iSGalleryModel, progress:CGFloat)
}

class iSImageController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var refreshButton: iSRefreshButton!
    
    weak var delegate: iSImageControllerDelegate?
    private var dataSource: [iSGalleryModel] = []
    private var page: Int = 1
    // 是否请求下一页
    private var isRequestNextPage: Bool = false
    
    var order: iSNetwork.Order = .latest {
        didSet {
            previousPageData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        scrollView.scrollerStyle = .overlay
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(iSImageItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.image"))
        
        // 点击刷新
        refreshButton.didClickButtonHandler = { [unowned self] in
            self.dataSource.removeAll()
            self.previousPageData()
        }
        
        // 注册滚动通知
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidScroll), name: NSScrollView.didLiveScrollNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidEndScroll), name: NSScrollView.didEndLiveScrollNotification, object: nil)
        // 图片质量更新通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateImageQualityAction), name: iSUpdateImageQualityNotification, object: nil)
        // 清理缓存通知
        NotificationCenter.default.addObserver(self, selector: #selector(cleanCacheAction), name: iSCleanCacheNotification, object: nil)
    }
    
    // MARK: < Network >
    private func previousPageData() {
        if dataSource.count > 0 {
            return
        }
        page = 1
        iSHUDManager.show(to: view)
        iSNetwork.gallery(order: order) { (result) in
            self.refreshButton.stopAnimaton()
            iSHUDManager.hide(to: self.view)
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
        iSNetwork.gallery(page, order: order) { [unowned self] (result) in
            self.refreshButton.stopAnimaton()
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
                let text = NSLocalizedString("iSNetworkFailed", comment: "未请求到数据，请稍后重试")
                iSHUDManager.show(to: self.view, text: text, delay: 2)
            }
        }
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
        dataSource.removeAll()
        previousPageData()
    }
}

extension iSImageController: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.image"), for: indexPath) as! iSImageItem
        let gallery: iSGalleryModel = dataSource[indexPath.item]
        item.gallery = gallery
        item.delegate = self
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = collectionView.frame.width
        let height = width * 0.6
        return CGSize.init(width: width, height: height)
    }
}

extension iSImageController: iSImageItemDelegate {
    func imageItem(_ item: iSImageItem, didClickDownloadAt model: iSGalleryModel?) {
        if let m = model {
            iSNetwork.download(m.largeImageURL, progress: { [unowned self] (progress) in
                self.delegate?.imageController(self, didDownloadAt: m, progress: progress)
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

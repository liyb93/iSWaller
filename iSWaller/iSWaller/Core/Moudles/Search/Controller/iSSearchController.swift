//
//  iSSearchController.swift
//  iSWaller
//
//  Created by liyb on 2020/6/30.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSSearchController: iSBaseController {

    @IBOutlet weak var navigationBar: iSNavigationBar!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var refreshButton: iSRefreshButton!
    @IBOutlet weak var progressView: iSDownloadProgressView!
    
    private lazy var searchBar: iSSearchBar = {
        let bar = iSSearchBar.init()
        bar.delegate = self
        bar.searchTextField.placeholderString = NSLocalizedString("iSSearchPlacholder", comment: "关键词搜索")
        return bar
    }()
    
    private lazy var colorPopover: NSPopover = {
        let p = NSPopover.init()
        p.appearance = NSAppearance.init(named: .darkAqua)
        let colorController = iSColorController.init()
        colorController.delegate = self
        p.contentViewController = colorController
        p.behavior = .applicationDefined
        return p
    }()
    
    private var monitor: iSEventMonitor!
    private var dataSource: [iSGalleryModel] = []
    private var page: Int = 1
    // 是否请求下一页
    private var isRequestNextPage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        // 注册滚动通知
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidScroll), name: NSScrollView.didLiveScrollNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidEndScroll), name: NSScrollView.didEndLiveScrollNotification, object: nil)
    }
    
    private func configUI() {
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(iSImageItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.image"))
        navigationBar.backButton.addTarget(self, action: #selector(backDidClickAction(_:)))
        navigationBar.titleView = self.searchBar
        navigationBar.rightButton.setTitle(NSLocalizedString("iSSearchTitle", comment: "搜索"))
        navigationBar.rightButton.addTarget(self, action: #selector(searchDidClickAction))
        progressView.delegate = self
        
        // 点击刷新
        refreshButton.didClickButtonHandler = { [unowned self] in
            self.collectionView.scroll(.zero)
            let color = searchBar.colors?["title"]
            self.searchGallery(color: color)
        }
        
        // 事件监听
        monitor = iSEventMonitor.init([.leftMouseDown, .rightMouseDown]) { [unowned self] (event) -> (Void) in
            if self.colorPopover.isShown {
                self.colorPopover.performClose(event)
            }
        }
    }
    
    // MARK: < Network >
    private func searchGallery(_ isChange: Bool = false, color: String? = nil, page: Int = 1) {
        let keyword = navigationBar.titleLabel.stringValue
        if keyword.count <= 0 {
            refreshButton.stopAnimaton()
            iSHUDManager.show(to: self.view, text: NSLocalizedString("iSSearchKeyword", comment: "请输入关键词"), delay: 2)
            return
        }
        iSHUDManager.show(to: view)
        iSNetwork.search(keyword, page: page, color: color) { [unowned self] (result) in
            iSHUDManager.hide(to: self.view)
            self.refreshButton.stopAnimaton()
            if let hits = result as? [String: Any], let data = hits["hits"] {
                let arr = (Array<iSGalleryModel>.deserialize(from: data as? [Any]) as? [iSGalleryModel]) ?? []
                if isChange {
                    self.dataSource.removeAll()
                }
                self.dataSource.append(contentsOf: arr)
                self.collectionView.reloadData()
            } else {
                let text = NSLocalizedString("iSNetworkFailed", comment: "未请求到数据，请稍后重试")
                iSHUDManager.show(to: self.view, text: text, delay: 2)
                if self.page > 1 {
                    self.page -= 1
                }
            }
        }
    }
    
    // MARK: < Action >
    @objc private func backDidClickAction(_ sender: Any) {
        navigationDelegate?.navigationController(self, didClickBackButtonAt: .search)
        navigationBar.titleLabel.stringValue = ""
        dataSource = []
        collectionView.reloadData()
    }
    
    @objc private func searchDidClickAction() {
        searchBar.searchTextField.window?.makeFirstResponder(self.view)
        let color = searchBar.colors?["title"]
        searchGallery(true, color: color)
    }
    
    @objc private func scrollViewDidScroll() {
        if let search = navigationBar.titleView as? iSSearchBar, search.searchTextField.stringValue.count <= 0 {
            return
        }
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
            page += 1
            let color = searchBar.colors?["title"]
            searchGallery(color: color, page: page)
        }
    }
}

extension iSSearchController: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        refreshButton.isHidden = dataSource.count > 0 ? false : true
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.image"), for: indexPath) as! iSImageItem
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

extension iSSearchController: iSImageItemDelegate {
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
 
extension iSSearchController: iSDownloadProgressViewDelegate {
    func downloadProgressView(didClickCancelButton view: iSDownloadProgressView) {
        iSNetwork.cancelDownload()
    }
}

extension iSSearchController: iSSearchBarDelegate {
    func searchBar(didClickedColor searchBar: iSSearchBar) {
        searchBar.searchTextField.window?.makeFirstResponder(self.view)
        if colorPopover.isShown {
            colorPopover.performClose(searchBar.colorButton)
            monitor.stop()
        } else {
            colorPopover.show(relativeTo: searchBar.colorButton.bounds, of: searchBar.colorButton, preferredEdge: .maxY)
            monitor.start()
        }
    }
}

extension iSSearchController: iSColorControllerDelegate {
    func colorController(_ controller: iSColorController, didSelectItemAt colors: [String : String]) {
        searchBar.colors = colors
        monitor.stop()
        colorPopover.performClose(searchBar.colorButton)
    }
}

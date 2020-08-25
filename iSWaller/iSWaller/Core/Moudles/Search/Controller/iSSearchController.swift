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
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var progressView: iSDownloadProgressView!
    
    private var dataSource: [iSGalleryModel] = []
    private var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private func configUI() {
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(iSImageItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.image"))
        navigationBar.backButton.addTarget(self, action: #selector(backDidClickAction(_:)))
        navigationBar.isSearch = true
        navigationBar.titleLabel.placeholderString = NSLocalizedString("iSSearchPlacholder", comment: "关键词搜索")
        navigationBar.rightButton.setTitle(NSLocalizedString("iSSearchTitle", comment: "搜索"))
        navigationBar.rightButton.addTarget(self, action: #selector(searchDidClickAction))
        previousButton.image = NSImage.init(named: "up")
        nextButton.image = NSImage.init(named: "down")
        previousButton.isHidden = true
        nextButton.isHidden = true
        nextButton.setBackgroundColor(.backgroundColor)
        nextButton.layer?.cornerRadius = 15.0
        nextButton.layer?.masksToBounds = true
        previousButton.setBackgroundColor(.backgroundColor)
        previousButton.layer?.cornerRadius = 15.0
        previousButton.layer?.masksToBounds = true
        progressView.delegate = self
    }
    
    // MARK: < Network >
    private func searchGallery(_ isChange: Bool = false, page: Int = 1) {
        let keyword = navigationBar.titleLabel.stringValue
        if keyword.count <= 0 {
            return
        }
        iSHUDManager.show(to: view)
        iSNetwork.search(keyword, page: page) { [unowned self] (result) in
            self.previousButton.isHidden = false
            iSHUDManager.hide(to: self.view)
            if let hits = result as? [String: Any], let data = hits["hits"] {
                let arr = (Array<iSGalleryModel>.deserialize(from: data as? [Any]) as? [iSGalleryModel]) ?? []
                if isChange {
                    self.dataSource.removeAll()
                }
                self.dataSource.append(contentsOf: arr)
                self.collectionView.reloadData()
                self.nextButton.isHidden = false
                self.previousButton.image = NSImage.init(named: "up")
            } else {
                let text = NSLocalizedString("iSNetworkFailed", comment: "未请求到数据，请稍后重试")
                iSHUDManager.show(to: self.view, text: text, delay: 2)
                if self.page > 1 {
                    self.page -= 1
                } else {
                    self.previousButton.image = NSImage.init(named: "refresh")
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
        nextButton.isHidden = true
        previousButton.isHidden = true
    }
    
    @objc private func searchDidClickAction() {
        navigationBar.titleLabel.resignFirstResponder()
        searchGallery(true)
    }
    
    @IBAction func previousDidClickAction(_ sender: Any) {
        collectionView.scroll(.zero)
        if dataSource.count <= 0 && navigationBar.titleLabel.stringValue.count > 0 {
            searchGallery()
        }
    }
    
    @IBAction func nextDidClickAction(_ sender: Any) {
        let contenSize = collectionView.collectionViewLayout?.collectionViewContentSize ?? .zero
        collectionView.scroll(NSPoint.init(x: 0, y: contenSize.height))
        page += 1
        searchGallery(page: page)
    }
}

extension iSSearchController: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
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

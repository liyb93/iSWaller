//
//  iSDownloadController.swift
//  iSWaller
//
//  Created by liyb on 2020/6/30.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSDownloadController: iSBaseController {

    @IBOutlet weak var navigationBar: iSNavigationBar!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var selectView: iSDownloadSelectView!
    @IBOutlet weak var progressView: iSDownloadProgressView!
    
    private var dataSource: [iSDownloadModel] = []
    private var isEditing: Bool = false
    private var selectDataSource: [iSDownloadModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        requestData()
    }
    
    private func configUI() {
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(iSDownloadItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.download"))
        navigationBar.backButton.addTarget(self, action: #selector(backDidClickAction(_:)))
        navigationBar.titleLabel.stringValue = NSLocalizedString("iSDownloadTitle", comment: "下载")
        navigationBar.rightButton.setImage(NSImage.init(named: "nav_edit"))
        navigationBar.rightButton.addTarget(self, action: #selector(selectDidClickAction(_:)))
        selectView.delegate = self
        progressView.delegate = self
    }
    
    func requestData() {
        if isViewLoaded {
            dataSource = iSDataManager.shared.getDownloads()
            collectionView.reloadData()
        }
    }
    
    private func showSelectView() {
        isEditing = true
        navigationBar.rightButton.setTitle(NSLocalizedString("iSDownloadSelectAll", comment: "全选"))
        navigationBar.backButton.setTitle(NSLocalizedString("iSDownloadCancel", comment: "取消"))
        selectView.showSelectView()
        collectionView.reloadData()
    }
    
    private func hideSelectView() {
        navigationBar.backButton.setImage(NSImage.init(named: "nav_back"))
        navigationBar.rightButton.setImage(NSImage.init(named: "nav_edit"))
        isEditing = false
        selectView.hideSelectView()
        selectDataSource = []
        collectionView.reloadData()
    }
    
    @objc private func backDidClickAction(_ sender: NSButton) {
        if isEditing {
            hideSelectView()
        } else {
            navigationDelegate?.navigationController(self, didClickBackButtonAt: .download)
        }
    }
    
    @objc private func selectDidClickAction(_ sender: NSButton) {
        if !isEditing {
            showSelectView()
        } else {
            selectDataSource = dataSource
            DispatchQueue.init(label: "selectAll").async {
                for data in self.dataSource {
                    let item = self.dataSource.firstIndex(of: data) ?? 0
                    let indexPath = IndexPath.init(item: item, section: 0)
                    DispatchQueue.main.async {
                        let cell = self.collectionView.item(at: indexPath)
                        cell?.isSelected = false
                        if self.selectDataSource.contains(data) {
                            cell?.isSelected = true
                        }
                    }
                }
            }
        }
    }
}

extension iSDownloadController: NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.download"), for: indexPath) as! iSDownloadItem
        item.data = dataSource[indexPath.item]
        item.isEditing = isEditing
        item.delegate = self
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = collectionView.frame.width
        let height = width * 0.6
        return CGSize.init(width: width, height: height)
    }
}

extension iSDownloadController: iSDownloadItemDelegate {
    func downloadItem(_ item: iSDownloadItem, didSelectItemAt model: iSDownloadModel?) {
        if let data = model {
            if isEditing {
                item.isSelected = !item.isSelected
                if item.isSelected {
                    selectDataSource.append(data)
                } else {
                    selectDataSource.removeAll(where: {$0==data})
                }
            } else {
                iSHUDManager.show(to: view)
                iSDataManager.shared.remove([data]) { [unowned self] in
                    self.hideSelectView()
                    self.requestData()
                    iSHUDManager.hide(to: self.view)
                }
            }
        }
    }
    
    func downloadItem(_ item: iSDownloadItem, didSetWallpaperItemAt model: iSDownloadModel?) {
        if let m = model, let url = m.fullUrl {
            iSNetwork.download(url, progress: { [unowned self] (progress) in
                self.progressView.showProgress(model, progress: progress)
            }) { (url) in
                if let u = url {
                    iSDataManager.shared.setDesktopImage(u, model: model)
                    iSDataManager.shared.currentWallpaper = model
                } else {
                    iSHUDManager.show(to: self.view, text: NSLocalizedString("iSDownloadError", comment: "下载失败"), delay: 2)
                }
            }
        }
    }
}

extension iSDownloadController: iSDownloadSelectViewDelegate {
    func downloadSelectView(didClickDelete selectView: iSDownloadSelectView) {
        iSHUDManager.show(to: view)
        iSDataManager.shared.remove(selectDataSource) { [unowned self] in
            self.hideSelectView()
            self.requestData()
            iSHUDManager.hide(to: self.view)
        }
    }
    
    func downloadSelectView(didClickAnitiElection selectView: iSDownloadSelectView) {
        DispatchQueue.init(label: "anitielection").async { [unowned self] in
            for data in self.dataSource {
                let item = self.dataSource.firstIndex(of: data) ?? 0
                let indexPath = IndexPath.init(item: item, section: 0)
                DispatchQueue.main.async {
                    let cell = self.collectionView.item(at: indexPath)
                    if !self.selectDataSource.contains(data) {
                        self.selectDataSource.append(data)
                        cell?.isSelected = true
                    } else {
                        cell?.isSelected = false
                        self.selectDataSource.removeAll(where: {$0==data})
                    }
                }
            }
        }
    }
}

extension iSDownloadController: iSDownloadProgressViewDelegate {
    func downloadProgressView(didClickCancelButton view: iSDownloadProgressView) {
        iSNetwork.cancelDownload()
    }
}

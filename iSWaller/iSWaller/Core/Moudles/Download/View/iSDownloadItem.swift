//
//  iSDownloadItem.swift
//  iSWaller
//
//  Created by liyb on 2020/7/4.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSDownloadItemDelegate: NSObjectProtocol {
    func downloadItem(_ item: iSDownloadItem, didSelectItemAt model: iSDownloadModel?)
    func downloadItem(_ item: iSDownloadItem, didSetWallpaperItemAt model: iSDownloadModel?)
}

class iSDownloadItem: NSCollectionViewItem {

    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var authorLabel: NSTextField!
    
    var data: iSDownloadModel? {
        didSet {
            configData()
        }
    }
    
    var isEditing: Bool = false {
        didSet {
            deleteButton.isHidden = !isEditing
            if isEditing {
                deleteButton.setImage(NSImage.init(named: "check_normal"))
            } else {
                deleteButton.setImage(NSImage.init(named: "trash"))
            }
        }
    }
    
    weak var delegate: iSDownloadItemDelegate?
    
    override var isSelected: Bool {
        didSet {
            isSelected ? deleteButton.setImage(NSImage.init(named: "check_select")) : deleteButton.setImage(NSImage.init(named: "check_normal"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEventListener()
    }
    
    private func configUI() {
        deleteButton.setImage(NSImage.init(named: "trash"))
        downloadButton.setBackgroundColor(NSColor.backgroundColor.withAlphaComponent(0.75))
        downloadButton.layer?.cornerRadius = 25.0
        downloadButton.layer?.masksToBounds = true
        downloadButton.setTitle(NSLocalizedString("iSSetWallpaper", comment: "设置壁纸"))
    }
    
    private func configEventListener() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeWhenFirstResponder, .inVisibleRect, .activeInActiveApp]
        let area = NSTrackingArea.init(rect: view.frame, options: options, owner: self, userInfo: nil)
        view.addTrackingArea(area)
        view.becomeFirstResponder()
    }
    
    private func configData() {
        if let model = data {
            let placeholder = NSImage.createImage(with: model.color, size: view.size)
            
            var urlString = model.mediumUrl
            if iSDataManager.shared.imageQuality == .large {
                urlString = model.fullUrl
            } else if iSDataManager.shared.imageQuality == .small {
                urlString = model.smallUrl
            }
            iconView.kf.setImage(with: URL.init(string: urlString ?? ""), placeholder: placeholder)
            if let author = model.user {
                let text = "Pixabay-\(author)"
                let attributedString = NSMutableAttributedString.init(string: text, attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10)])
                let authorRange = (text as NSString).range(of: author)
                let platformRange = (text as NSString).range(of: "Pixabay")
                attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: authorRange)
                attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: platformRange)
                authorLabel.attributedStringValue = attributedString
                authorLabel.alignment = .center
            }
        }
    }
    
    // 退出区域
    override func mouseExited(with event: NSEvent) {
        if !isEditing {
            downloadButton.isHidden = true
            authorLabel.isHidden = true
            deleteButton.isHidden = true
        }
    }
    
    // 进入区域
    override func mouseEntered(with event: NSEvent) {
        if !isEditing {
            downloadButton.isHidden = false
            authorLabel.isHidden = false
            deleteButton.isHidden = false
        }
    }
    
    @IBAction func deleteDidClickAction(_ sender: Any) {
        delegate?.downloadItem(self, didSelectItemAt: data)
    }
    
    @IBAction func wallpaperDidClickAction(_ sender: Any) {
        delegate?.downloadItem(self, didSetWallpaperItemAt: data)
    }
}

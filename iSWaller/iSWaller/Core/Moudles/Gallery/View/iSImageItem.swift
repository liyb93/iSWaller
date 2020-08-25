//
//  iSImageItem.swift
//  iSWaller
//
//  Created by liyb on 2020/6/9.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa
import Kingfisher

protocol iSImageItemDelegate: NSObjectProtocol {
    func imageItem(_ item: iSImageItem, didClickDownloadAt model: iSGalleryModel?)
}

class iSImageItem: NSCollectionViewItem {

    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var authorLabel: NSTextField!
    @IBOutlet weak var iconView: NSImageView!
    
    weak var delegate: iSImageItemDelegate?
    
    var gallery: iSGalleryModel? {
        didSet {
            configData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEventListener()
    }
    
    private func configUI() {
        downloadButton.setBackgroundColor(NSColor.backgroundColor.withAlphaComponent(0.75))
        downloadButton.layer?.cornerRadius = 25.0
        downloadButton.layer?.masksToBounds = true
        let title = NSLocalizedString("iSSetWallpaper", comment: "设置壁纸")
        downloadButton.setTitle(title)
    }
    
    private func configEventListener() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeWhenFirstResponder, .inVisibleRect, .activeInActiveApp]
        let area = NSTrackingArea.init(rect: view.frame, options: options, owner: self, userInfo: nil)
        view.addTrackingArea(area)
        view.becomeFirstResponder()
    }
    
    private func configData() {
        if let model = gallery {
            let placeholder = NSImage.createImage(with: model.color, size: view.size)
            
            var urlString = model.webformatURL
            if iSDataManager.shared.imageQuality == .large {
                urlString = model.largeImageURL
            } else if iSDataManager.shared.imageQuality == .small {
                urlString = model.previewURL
            }
            iconView.kf.setImage(with: URL.init(string: urlString), placeholder: placeholder)
            let text = "Pixabay-\(model.user)"
            let attributedString = NSMutableAttributedString.init(string: text, attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10)])
            let authorRange = (text as NSString).range(of: model.user)
            let platformRange = (text as NSString).range(of: "Pixabay")
            attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: authorRange)
            attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: platformRange)
            authorLabel.attributedStringValue = attributedString
            authorLabel.alignment = .center
        }
    }
    
    // 退出区域
    override func mouseExited(with event: NSEvent) {
        downloadButton.isHidden = true
        authorLabel.isHidden = true
    }
    
    // 进入区域
    override func mouseEntered(with event: NSEvent) {
        downloadButton.isHidden = false
        authorLabel.isHidden = false
    }
    
    @IBAction func downloadDidClickAction(_ sender: Any) {
        delegate?.imageItem(self, didClickDownloadAt: gallery)
    }
}

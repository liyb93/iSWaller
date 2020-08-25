//
//  iSAboutController.swift
//  iSWaller
//
//  Created by liyb on 2020/6/30.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSAboutController: iSBaseController {

    @IBOutlet weak var navigationBar: iSNavigationBar!
    @IBOutlet weak var textLabel: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private func configUI() {
        navigationBar.backButton.addTarget(self, action: #selector(backDidClickAction(_:)))
        navigationBar.titleLabel.stringValue = NSLocalizedString("iSAboutTitle", comment: "关于我们")
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        scrollView.horizontalScrollElasticity = .none
        scrollView.verticalScrollElasticity = .none
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.setBackgroundColor(.clear)
        textView.layer?.borderWidth = 0
        textView.isEditable = false
        textView.textColor = .separator
        textView.string = NSLocalizedString("iSAboutDesc", comment: "")
        
        // 配置名称和版本
        var attributedString: NSMutableAttributedString!
        if let appName = iSDataManager.shared.appName {
            var text: String = appName
            var range: NSRange?
            if let version = iSDataManager.shared.appVersion {
                text = appName.appending(" v\(version)")
                range = (text as NSString).range(of: " v\(version)")
            }
            attributedString = NSMutableAttributedString.init(string: text, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: NSColor.separator])
            if let r = range {
                attributedString.addAttributes([NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10)], range: r)
            }
        } else {
            attributedString = NSMutableAttributedString.init(string: "iSWaller", attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: NSColor.separator])
        }
        textLabel.attributedStringValue = attributedString
    }
    
    // MARK: < Action >
    @objc private func backDidClickAction(_ sender: Any) {
        navigationDelegate?.navigationController(self, didClickBackButtonAt: .about)
    }
}

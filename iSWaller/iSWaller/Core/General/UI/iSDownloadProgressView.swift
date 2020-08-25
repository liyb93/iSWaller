//
//  iSDownloadProgressView.swift
//  iSWaller
//
//  Created by liyb on 2020/7/4.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSDownloadProgressViewDelegate {
    func downloadProgressView(didClickCancelButton view: iSDownloadProgressView)
}

class iSDownloadProgressView: NSView {

    private lazy var imageView: NSImageView = {
        let view = NSImageView.init()
        view.imageScaling = .scaleAxesIndependently
        return view
    }()
    
    private lazy var progressView: NSProgressIndicator = {
        let view = NSProgressIndicator.init()
        view.isIndeterminate = false
        view.isBezeled = true
        view.controlSize = .small
        view.style = .bar
        view.minValue = 0
        view.maxValue = 1
        view.doubleValue = 0
        return view
    }()
    
    private lazy var cancelButton: NSButton = {
        let button = NSButton.init()
        button.setImage(NSImage.init(named: "cancel"))
        button.addTarget(self, action: #selector(cancelDidClickAction))
        return button
    }()
    
    var delegate: iSDownloadProgressViewDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layout() {
        super.layout()
        imageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(imageView.snp.height)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(self.snp.height).multipliedBy(0.5)
        }
        progressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(imageView)
            make.left.equalTo(imageView.snp.right).offset(10)
            make.right.equalTo(cancelButton.snp.left).offset(-10)
        }
    }
    
    private func setup() {
        setBackgroundColor(NSColor.backgroundColor.withAlphaComponent(0.7))
        addSubview(imageView)
        addSubview(progressView)
        addSubview(cancelButton)
    }
    
    func showProgress(_ model: Any?, progress: CGFloat) {
        progressView.doubleValue = Double(progress)
        NSAnimationContext.runAnimationGroup { [unowned self] (context) in
            context.duration = 0.3
            if progress >= 1.0 {
                self.isHidden = true
            } else {
                self.isHidden = false
            }
        }
        if model is iSGalleryModel, let m = model as? iSGalleryModel {
            let placeholder = NSImage.createImage(with: m.color, size: imageView.size)
            imageView.kf.setImage(with: URL.init(string: m.previewURL), placeholder: placeholder)
        } else if model is iSDownloadModel, let m = model as? iSDownloadModel {
            let placeholder = NSImage.createImage(with: m.color, size: imageView.size)
            imageView.kf.setImage(with: URL.init(string: m.smallUrl ?? ""), placeholder: placeholder)
        }
    }
    
    @objc private func cancelDidClickAction() {
        delegate?.downloadProgressView(didClickCancelButton: self)
        NSAnimationContext.runAnimationGroup { [unowned self] (context) in
            context.duration = 0.3
            self.isHidden = true
        }
    }
}

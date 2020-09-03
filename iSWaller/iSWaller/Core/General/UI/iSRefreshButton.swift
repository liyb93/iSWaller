//
//  iSRefreshButton.swift
//  iSWaller
//
//  Created by liyb on 2020/9/3.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSRefreshButton: NSView {

    private(set) lazy var imageView: NSImageView = {
        let view = NSImageView.init()
        view.image = NSImage.init(named: "refresh")
        return view
    }()
    
    var didClickButtonHandler: (()->())?
    
    init() {
        super.init(frame: .zero)
        configUI()
        configEventListener()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
        configEventListener()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
        configEventListener()
    }
    
    override func layout() {
        super.layout()
        imageView.frame = .init(x: 5, y: 5, width: 30, height: 30)
    }
    
    private func configUI() {
        setBackgroundColor(NSColor.backgroundColor.withAlphaComponent(0.75))
        setCornerRadius(20)
        addSubview(imageView)
    }
    
    private func configEventListener() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeWhenFirstResponder, .inVisibleRect, .activeInActiveApp]
        let area = NSTrackingArea.init(rect: frame, options: options, owner: self, userInfo: nil)
        addTrackingArea(area)
        becomeFirstResponder()
    }
    
    override func mouseUp(with event: NSEvent) {
        if !imageView.isRotationAnimaton() {
            startAnimaton()
            didClickButtonHandler?()
        }
    }
    
    func startAnimaton() {
        imageView.startRotationAnimaton()
    }
    
    func stopAnimaton() {
        imageView.stopRotationAnimaton()
    }
}

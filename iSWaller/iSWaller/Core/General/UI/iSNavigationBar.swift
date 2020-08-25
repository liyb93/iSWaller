//
//  iSNavigationBar.swift
//  iSWaller
//
//  Created by liyb on 2020/7/1.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa
import SnapKit

class iSNavigationBar: NSView {

    private(set) lazy var backButton: NSButton = {
        let button = NSButton.init()
        button.setImage(NSImage.init(named: "nav_back"))
        return button
    }()
    
    private(set) lazy var titleLabel: iSTextField = {
        let label = iSTextField.init()
        label.isEditable = false
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: 18)
        label.isBordered = false
        label.isBezeled = false
        label.drawsBackground = false
        label.backgroundColor = .clear
        label.wantsLayer = true
        label.layer?.cornerRadius = 12.5
        return label
    }()
    
    private(set) lazy var rightButton: NSButton = {
        let button = NSButton.init()
        button.setTitle("")
        return button
   }()
    
    var isSearch: Bool = false {
        didSet {
            if isSearch {
                titleLabel.isEditable = true
                titleLabel.alignment = .center
                titleLabel.font = NSFont.systemFont(ofSize: 15)
                titleLabel.isBordered = true
                titleLabel.isBezeled = true
                titleLabel.bezelStyle = .squareBezel
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
    
    private func configUI() {
        setBackgroundColor(.backgroundColor)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(rightButton)
    }
    
    override func layout() {
        super.layout()
        backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(self.snp.height).multipliedBy(0.5)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }
        rightButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(backButton)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(30)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right).offset(10)
            make.right.equalTo(rightButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
}

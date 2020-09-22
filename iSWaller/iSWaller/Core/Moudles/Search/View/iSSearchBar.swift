//
//  iSSearchBar.swift
//  iSWaller
//
//  Created by liyb on 2020/9/10.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSSearchBarDelegate {
    func searchBar(didClickedColor searchBar: iSSearchBar)
}

class iSSearchBar: NSView {

    private(set) lazy var colorButton: NSButton = {
        let button = NSButton.init()
        button.setImage(NSImage.init(named: "transparent_color"))
        button.addTarget(self, action: #selector(colorDidClickAction))
        return button
    }()
    
    private(set) lazy var searchTextField: iSTextField = {
        let textField = iSTextField.init()
        textField.isEditable = true
        textField.alignment = .left
        textField.font = NSFont.systemFont(ofSize: 17)
        textField.isBordered = true
        textField.isBezeled = true
        textField.stringValue = ""
        textField.bezelStyle = .squareBezel
        textField.textColor = NSColor.white.withAlphaComponent(0.75)
        return textField
    }()
    
    var colors: [String: String]? {
        didSet {
            if let c = colors {
                let image = NSImage.init(named: c["image"] ?? "transparent_color")
                colorButton.setImage(image)
            }
        }
    }
    
    var delegate: iSSearchBarDelegate?
    
    init() {
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        colorButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.width.height.equalTo(self.snp.height).multipliedBy(0.5)
        }
        searchTextField.snp.makeConstraints { (make) in
            make.left.equalTo(colorButton.snp.right).offset(5)
            make.right.top.bottom.equalToSuperview()
        }
    }
    
    private func configUI() {
        addSubview(colorButton)
        addSubview(searchTextField)
        setBorder(NSColor.lightGray.withAlphaComponent(0.75))
        setCornerRadius(5.0)
    }
    
    @objc private func colorDidClickAction() {
        delegate?.searchBar(didClickedColor: self)
    }
}

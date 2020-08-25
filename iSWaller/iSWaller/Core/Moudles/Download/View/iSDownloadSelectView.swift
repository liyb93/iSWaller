//
//  iSDownloadSelectView.swift
//  iSWaller
//
//  Created by liyb on 2020/7/9.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSDownloadSelectViewDelegate: NSObjectProtocol {
    func downloadSelectView(didClickAnitiElection selectView: iSDownloadSelectView)
    func downloadSelectView(didClickDelete selectView: iSDownloadSelectView)
}

class iSDownloadSelectView: NSView {
    
    private lazy var antiElectionButton: NSButton = {
        let button = NSButton.init()
        button.setTitle(NSLocalizedString("iSDownloadAntiElection", comment: "反选"))
        button.addTarget(self, action: #selector(antiElectionDidClickAction(_:)))
        return button
    }()
    
    private lazy var deleteButton: NSButton = {
        let button = NSButton.init()
        button.setTitle(NSLocalizedString("iSDownloadDelete", comment: "删除"))
        button.addTarget(self, action: #selector(deleteDidClickAction(_:)))
        return button
    }()
    
    private lazy var horizontalLineView: NSView = {
        let view = NSView.init()
        view.setBackgroundColor(.separator)
        return view
    }()
    
    private lazy var verticalLineView: NSView = {
        let view = NSView.init()
        view.setBackgroundColor(.separator)
        return view
    }()
    
    var delegate: iSDownloadSelectViewDelegate?
    
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
        horizontalLineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        verticalLineView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalTo(0.5)
        }
        antiElectionButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(verticalLineView.snp.left)
        }
        deleteButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(verticalLineView.snp.right)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
    }
    
    private func setup() {
        setBackgroundColor(NSColor.backgroundColor.withAlphaComponent(0.7))
        addSubview(antiElectionButton)
        addSubview(deleteButton)
        addSubview(horizontalLineView)
        addSubview(verticalLineView)
    }
    
    func showSelectView() {
        NSAnimationContext.runAnimationGroup { [unowned self] (context) in
            context.duration = 0.3
            self.isHidden = false
        }
    }
    
    func hideSelectView() {
        NSAnimationContext.runAnimationGroup { [unowned self] (context) in
            context.duration = 0.3
            self.isHidden = true
        }
    }
    
    @objc func deleteDidClickAction(_ btn: NSButton) {
        delegate?.downloadSelectView(didClickDelete: self)
    }
    
    @objc func antiElectionDidClickAction(_ btn: NSButton) {
        delegate?.downloadSelectView(didClickAnitiElection: self)
    }
}

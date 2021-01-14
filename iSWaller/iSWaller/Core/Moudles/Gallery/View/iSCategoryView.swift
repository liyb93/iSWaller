//
//  iSCategoryView.swift
//  iSWaller
//
//  Created by liyb on 2020/9/4.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSCategoryViewDelegate: NSObjectProtocol {
    func categoryView(_ view: iSCategoryView, didSelectItemAt index:Int)
}

class iSCategoryView: NSView {
    private lazy var newButton: NSButton = {
        let button = NSButton.init()
        button.setTitle(NSLocalizedString("iSCategoryLast", comment: "最新"))
        button.setTitleColor(.init(0xfa1616))
        button.addTarget(self, action: #selector(newDidClickAction(_:)))
        return button
    }()
    
    private lazy var popularButton: NSButton = {
        let button = NSButton.init()
        button.setTitle(NSLocalizedString("iSCategoryPopular", comment: "流行"))
        button.setTitleColor(.init(0xA1A1A1))
        button.addTarget(self, action: #selector(popularDidClickAction(_:)))
        return button
    }()
    
    private lazy var lineView: NSView = {
        let view = NSView.init()
        view.setBackgroundColor(.init(0xfa1616))
        view.setCornerRadius(1.0)
        return view
    }()
    
    private var oldTransform: CATransform3D? = CATransform3DIdentity
    weak var delegate: iSCategoryViewDelegate?
    var selectedIndex: Int = 0 {
        didSet {
            if selectedIndex == 1 {
                popularDidClickAction(popularButton)
            } else {
                newDidClickAction(newButton)
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
    
    override func layout() {
        super.layout()
        newButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        popularButton.snp.makeConstraints { (make) in
            make.left.equalTo(newButton.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalTo(newButton)
            make.width.equalTo(newButton).multipliedBy(0.5)
            make.height.equalTo(2)
        }
    }
    
    private func configUI() {
        addSubview(newButton)
        addSubview(popularButton)
        addSubview(lineView)
    }
    
    @objc private func newDidClickAction(_ sender: NSButton) {
        sender.setTitleColor(.init(0xfa1616))
        popularButton.setTitleColor(.init(0xA1A1A1))
        lineView.translationAnimation(oldTransform, to: CATransform3DIdentity, duration: 0.3)
        oldTransform = CATransform3DIdentity
        delegate?.categoryView(self, didSelectItemAt: 0)
    }
    
    @objc private func popularDidClickAction(_ sender: NSButton) {
        sender.setTitleColor(.init(0xfa1616))
        newButton.setTitleColor(.init(0xA1A1A1))
        let to = CATransform3DMakeTranslation(sender.left, 0, 0)
        lineView.translationAnimation(oldTransform, to: to, duration: 0.3)
        oldTransform = to
        delegate?.categoryView(self, didSelectItemAt: 1)
    }
}

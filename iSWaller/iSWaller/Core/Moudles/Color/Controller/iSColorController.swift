//
//  iSColorController.swift
//  iSWaller
//
//  Created by liyb on 2020/9/18.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

protocol iSColorControllerDelegate: NSObjectProtocol {
    func colorController(_ controller: iSColorController, didSelectItemAt colors: [String: String])
}

class iSColorController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    weak var delegate: iSColorControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.hasVerticalScroller = false
        scrollView.verticalScroller?.alphaValue = 0
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        clipView.drawsBackground = false
        clipView.backgroundColor = .clear
        collectionView.backgroundColors = [.clear]
        collectionView.register(iSColorItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.color"))
    }
    
}

extension iSColorController: NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearchColors.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "is.liyb.color"), for: indexPath) as! iSColorItem
        let colors = isSearchColors[indexPath.item]
        item.titleLabel.stringValue = colors["title"] ?? ""
        item.iconView.image = NSImage.init(named: colors["image"] ?? "")
        item.delegate = self
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = collectionView.frame.width
        return CGSize.init(width: width, height: 30)
    }
}

extension iSColorController: iSColorItemDelegate {
    func colorItem(didSelect item: iSColorItem) {
        if let index = collectionView.indexPath(for: item)?.item {
            delegate?.colorController(self, didSelectItemAt: isSearchColors[index])
        }
    }
}

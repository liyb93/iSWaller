//
//  iSDownloadModel.swift
//  iSWaller
//
//  Created by liyb on 2020/7/7.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa

class iSDownloadModel: NSObject, NSCoding {
    var fullUrl: String? = nil
    var smallUrl: String? = nil
    var mediumUrl: String? = nil
    var wid : String? = nil
    var user: String? = nil
    var color: NSColor = NSColor.placeholderColor()
    
    init(_ gallery: iSGalleryModel? = nil) {
        super.init()
        if let model = gallery {
            fullUrl = model.largeImageURL
            smallUrl = model.previewURL
            mediumUrl = model.webformatURL
            wid = model.id
            user = model.user
        }
    }
    
    required init?(coder: NSCoder) {
        fullUrl = coder.decodeObject(forKey: "fullUrl") as? String
        smallUrl = coder.decodeObject(forKey: "smallUrl") as? String
        mediumUrl = coder.decodeObject(forKey: "mediumUrl") as? String
        wid = coder.decodeObject(forKey: "wid") as? String
        user = coder.decodeObject(forKey: "user") as? String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(fullUrl, forKey: "fullUrl")
        coder.encode(smallUrl, forKey: "smallUrl")
        coder.encode(mediumUrl, forKey: "mediumUrl")
        coder.encode(wid, forKey: "wid")
        coder.encode(user, forKey: "user")
    }
    
}

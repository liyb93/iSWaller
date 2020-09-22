//
//  Macro.swift
//  iSWaller
//
//  Created by liyb on 2020/7/3.
//  Copyright © 2020 liyb. All rights reserved.
//

import Foundation

let iSPixabayAccesskey = "12956784-91c84f326fcbd73df660f8c5b"

// 图片质量
let iSUpdateImageQualityNotification = NSNotification.Name.init(rawValue: "is.updateImageQualityNotification")
// 清理缓存
let iSCleanCacheNotification = NSNotification.Name.init(rawValue: "is.cleanCacheNotification")

let iSAutoChangeTimes: [String] = [NSLocalizedString("iSAutoTimeOff", comment: "关"), NSLocalizedString("iSAutoTime15", comment: "15分钟"), NSLocalizedString("iSAutoTime30", comment: "30分钟"), NSLocalizedString("iSAutoTime45", comment: "45分钟"), NSLocalizedString("iSAutoTime60", comment: "1小时"), NSLocalizedString("iSAutoTime120", comment: "2小时"), NSLocalizedString("iSAutoTime1", comment: "1天")]
let iSImageQualitys: [String] = [NSLocalizedString("iSPreviewQuilatySmall", comment: "低质量"), NSLocalizedString("iSPreviewQuilatyMedium", comment: "中等质量"), NSLocalizedString("iSPreviewQuilatyFull", comment: "高质量")]

let iSPlaceholderColors: [String] = ["24a19c", "0f4c75", "6ebfb5", "3b2e5a", "fe91ca", "251f44", "e8505b", "2bb2bb", "162447", "e19999", "eb6383", "fa744f", "4d3e3e", "562349", "63b7af", "58b4ae", "00005c", "bb3b0e", "c3edea", "00263b", "565d47", "d92027", "10375c", "222831", "364f6b", "aa96da", "8785a2", "2b2e4a", "e84545", "ffb6b9", "48466d", "00b8a9", "ffcfdf", "522546", "c06c84", "355c7d", "f07b3f", "303841", "f85f73", "00e0ff", "62d2a2", "1fab89", "15b7b9", "ebfffa", "fefaec", "155263", "aedefc", "7c7575", "fbf0f0", "9e579d", "a393eb", "ff847c", "726a95"]

let isSearchColors: [[String: String]] = [["title": "grayscale", "image": "grayscale_color"], ["title": "transparent", "image": "transparent_color"], ["title": "red", "image": "red_color"], ["title": "orange", "image": "orange_color"], ["title": "yellow", "image": "yellow_color"], ["title": "green", "image": "green_color"], ["title": "turquoise", "image": "turquoise_color"], ["title": "blue", "image": "blue_color"], ["title": "lilac", "image": "lilac_color"], ["title": "pink", "image": "pink_color"], ["title": "white", "image": "white_color"], ["title": "gray", "image": "gray_color"], ["title": "black", "image": "black_color"], ["title": "brown", "image": "brown_color"]]

// log
func iSLog(_ item: Any) {
    #if DEBUG
    print(item)
    #endif
}

//
//  NSImage+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/7/3.
//  Copyright © 2020 liyb. All rights reserved.
//

import AppKit

extension NSImage {
    class func createImage(with color: NSColor, size: CGSize) -> NSImage {
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        let image = NSImage.init(size: rect.size)
        image.lockFocus()
        color.drawSwatch(in: rect)
        image.unlockFocus()
        return image
    }
    
    // 获取图片格式
    class func type(for data: Data) -> String? {
        var buffer = [UInt8](repeating: 0, count: 1)
        data.copyBytes(to: &buffer, count: 1)
        
        switch buffer {
        case [0xFF]: return ".jpg"
        case [0x89]: return ".png"
        case [0x47]: return ".gif"
        case [0x49],[0x4D]: return ".tiff"
        case [0x52] where data.count >= 12:
            if let str = String(data: data[0...11], encoding: .ascii), str.hasPrefix("RIFF"), str.hasSuffix("WEBP") {
                return ".webp"
            }
        case [0x00] where data.count >= 12:
            if let str = String(data: data[8...11], encoding: .ascii) {
                let HEICBitMaps = Set(["heic", "heis", "heix", "hevc", "hevx"])
                if HEICBitMaps.contains(str) {
                    return ".heic"
                }
                let HEIFBitMaps = Set(["mif1", "msf1"])
                if HEIFBitMaps.contains(str) {
                    return ".heif"
                }
            }
        default: break;
        }
        return nil
    }
}

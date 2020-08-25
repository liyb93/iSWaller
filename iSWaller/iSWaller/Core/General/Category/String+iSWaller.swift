//
//  String+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/7/1.
//  Copyright © 2020 liyb. All rights reserved.
//

import AppKit
import CommonCrypto

extension String {
    func height(_ font: NSFont, width: CGFloat) -> CGFloat {
        let rect = (self as NSString).boundingRect(with: CGSize.init(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size.height + 10
    }
    
    func width(_ font: NSFont, height: CGFloat) -> CGFloat {
        let rect = (self as NSString).boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size.width + 10
    }
    
    func md5() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: length)
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        // 去除斜杠
        var result = digestData.base64EncodedString()
        while result.contains("/") {
            result = result.replacingOccurrences(of: "/", with: "")
        }
        return result
    }
    
    func base64() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
}

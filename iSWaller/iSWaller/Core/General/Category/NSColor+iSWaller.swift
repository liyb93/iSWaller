//
//  NSColor+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/7/1.
//  Copyright © 2020 liyb. All rights reserved.
//

import AppKit

extension NSColor {
    class var backgroundColor: NSColor {
        get {
            return .init(0x373737)
        }
    }
    
    class var separator: NSColor {
        get {
            return .init(0xDEDEDE)
        }
    }
    
    convenience init(_ hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    convenience init(_ hex: UInt) {
        var r: UInt = 0, g: UInt = 0, b: UInt = 0;
        var a: UInt = 0xFF
        var rgb = hex

        if (hex & 0xFFFF0000) == 0 {
            a = 0xF
            if hex & 0xF000 > 0 {
                a = hex & 0xF
                rgb = hex >> 4
            }
            r = (rgb & 0xF00) >> 8
            r = (r << 4) | r

            g = (rgb & 0xF0) >> 4
            g = (g << 4) | g

            b = rgb & 0xF
            b = (b << 4) | b
            
            a = (a << 4) | a
        } else {
            if hex & 0xFF000000 > 0 {
                a = hex & 0xFF
                rgb = hex >> 8
            }
            r = (rgb & 0xFF0000) >> 16
            g = (rgb & 0xFF00) >> 8
            b = rgb & 0xFF
        }
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        let alpha = CGFloat(a) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func randomColor() -> NSColor {
        let r = CGFloat(arc4random() % 255)
        let g = CGFloat(arc4random() % 255)
        let b = CGFloat(arc4random() % 255)
        let a = CGFloat((arc4random() % 9) + 1) * 0.1
        return NSColor.init(red: r, green: g, blue: b, alpha: a)
    }
    
    static func placeholderColor() -> NSColor {
        let index = Int(arc4random() % uint32(iSPlaceholderColors.count))
        let color = iSPlaceholderColors[index]
        return NSColor.init(color)
    }
}

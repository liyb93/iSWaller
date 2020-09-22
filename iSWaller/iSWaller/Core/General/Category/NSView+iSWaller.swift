//
//  NSView+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/6/30.
//  Copyright © 2020 liyb. All rights reserved.
//

import AppKit

extension NSView {
    // MARK: < Frame >
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var rect = frame
            rect.origin = newValue
            frame = rect
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }
    
    var left: CGFloat {
        get {
            return origin.x
        }
        set {
            origin.x = newValue
        }
    }
    
    var top: CGFloat {
        get {
            return origin.y
        }
        set {
            origin.y = newValue
        }
    }
    
    var width: CGFloat {
        get {
            return size.width
        }
        set {
            size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return size.height
        }
        set {
            size.height = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return width + left
        }
        set {
            width = newValue - left
        }
    }
    
    var bottom: CGFloat {
        get {
            return height + top
        }
        set {
            height = newValue - top
        }
    }
    
    var center: CGPoint {
        get {
            return CGPoint.init(x: width/2.0, y: height/2.0)
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        }
    }

    // MARK: < Color >
    func setBackgroundColor(_ color: NSColor?) {
        wantsLayer = true
        layer?.backgroundColor = color?.cgColor
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        wantsLayer = true
        layer?.cornerRadius = radius
        layer?.masksToBounds = true
    }
    
    func setBorder(_ color: NSColor, width: CGFloat = 1.0) {
        wantsLayer = true
        layer?.borderColor = color.cgColor
        layer?.borderWidth = width
    }
    
    // MARK: < Animation >
    func translationAnimation(_ from: CATransform3D?, to: CATransform3D?, duration: CFTimeInterval = 0.5) {
        let animation = CABasicAnimation.init(keyPath: "transform")
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.fromValue = from
        animation.toValue = to
        layer?.add(animation, forKey: "translation.animation")
    }
    
    func startRotationAnimaton(_ clockwise: Bool = false) {
        wantsLayer = true
        let oldFrame = layer?.frame
        layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer?.frame = oldFrame ?? .zero
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        let from = 0
        let to = CGFloat.pi * 2
        animation.fromValue = clockwise ? from : to
        animation.toValue = clockwise ? to : from
        animation.duration = 1
        animation.isAdditive = true
        animation.repeatDuration = CFTimeInterval.infinity
        animation.isRemovedOnCompletion = false
        layer?.add(animation, forKey: "rotation.animation")
    }
    
    func stopRotationAnimaton() {
        layer?.removeAnimation(forKey: "rotation.animation")
    }
    
    func isRotationAnimaton() -> Bool {
        if (layer?.animation(forKey: "rotation.animation")) != nil {
            return true
        }
        return false
    }
}

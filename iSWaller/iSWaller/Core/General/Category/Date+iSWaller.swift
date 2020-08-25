//
//  Date+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/7/8.
//  Copyright © 2020 liyb. All rights reserved.
//

import Foundation

extension Date {
    static func currentDate(_ format: String? = nil) -> String {
        let date = Date.init()
        let formatter = DateFormatter.init()
        formatter.dateFormat = format ?? "yyyy-HH-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}

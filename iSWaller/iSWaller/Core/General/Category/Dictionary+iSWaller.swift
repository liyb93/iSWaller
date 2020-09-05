//
//  Dictionary+iSWaller.swift
//  iSWaller
//
//  Created by liyb on 2020/9/4.
//  Copyright © 2020 liyb. All rights reserved.
//

import Foundation

extension Dictionary {
    func toParameterString() -> String? {
        var params: String = "?"
        for (key,value) in self {
            guard let k = key as? String else {
                return nil
            }
            var v = value as? String
            if v == nil {
                v = "\(value)"
            }
            params.append("\(k)=\(v!)&")
        }
        params.removeLast()
        return params
    }
}

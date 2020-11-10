//
//  NSObjectProtocolExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/31.
//

import Foundation

extension NSObjectProtocol {
    static var className: String {
        return String(describing: self)
    }
}

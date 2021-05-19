//
//  Emptiable.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/19.
//

import Foundation

enum Emptiable<T: Hashable>: Hashable {
    case content(T)
    case empty

    var content: T? {
        if case let .content(content) = self {
            return content
        } else {
            return nil
        }
    }
}

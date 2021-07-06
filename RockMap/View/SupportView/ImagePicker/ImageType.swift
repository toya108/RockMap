//
//  ImageType.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/29.
//

import Foundation

enum ImageType {
    case header
    case normal
    case icon

    var limit: Int {
        switch self {
            case .header, .icon:
                return 1
                
            default:
                return 10
        }
    }

    var typeName: String {
        switch self {
            case .header:
                return "header"

            case .normal:
                return "normal"

            case .icon:
                return "icon"
        }
    }
}

struct ImageURL {
    let imageType: ImageType
    let urls: [URL]
}

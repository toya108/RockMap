//
//  ImageType.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/29.
//

enum ImageType {
    case header
    case normal

    var limit: Int {
        switch self {
            case .header:
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

        }
    }
}

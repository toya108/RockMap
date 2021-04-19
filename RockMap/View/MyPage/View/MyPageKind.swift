//
//  MyPageKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import Foundation

extension MyPageViewController {

    enum SectionLayoutKind: CaseIterable {
        case name

        var headerTitle: String {
            switch self {
                case .name:
                    return "ネーム"

                default:
                    return ""

            }
        }

        var headerIdentifer: String {
            switch self {
                case .name:
                    return ""
            }
        }
    }

    enum ItemKind: Hashable {
        case name
    }

}

//
//  MyPageKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import Foundation

extension MyPageViewController {

    enum SectionLayoutKind: CaseIterable {
        case headerImage
        case user
        case socialLink

        var headerTitle: String {
            switch self {
                default:
                    return ""

            }
        }

        var headerIdentifer: String {
            switch self {
                default:
                    return ""
            }
        }

        var initialItems: [ItemKind] {
            switch self {
                case .headerImage:
                    return [.headerImage(.init())]

                case .user:
                    return [.user]

                default:
                    return []
            }
        }
    }

    enum ItemKind: Hashable {
        case headerImage(StorageManager.Reference)
        case user
        case socialLink(FIDocument.User.SocialLinkType)
    }

}

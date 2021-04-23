//
//  MyPageKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import Foundation

extension MyPageViewController {

    enum SectionKind: CaseIterable {
        case headerImage
        case user
        case socialLink
        case introduction
        case climbedNumber
        case registered

        var headerTitle: String {
            switch self {
                case .climbedNumber:
                    return "完登数"

                case .registered:
                    return "登録した岩/課題"

                default:
                    return ""

            }
        }

        var headerIdentifer: String {
            switch self {
                case .climbedNumber, .registered:
                    return TitleSupplementaryView.className

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

                case .introduction:
                    return [.introduction]

                case .climbedNumber:
                    return [.climbedNumber]

                case .registered:
                    return [.registeredRock, .registeredCourse]

                default:
                    return []
            }
        }
    }

    enum ItemKind: Hashable {
        case headerImage(StorageManager.Reference)
        case user
        case socialLink(FIDocument.User.SocialLinkType)
        case introduction
        case climbedNumber
        case registeredRock
        case registeredCourse
    }

}

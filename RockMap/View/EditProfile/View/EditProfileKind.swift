//
//  EditProfileKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/10.
//

import Foundation

import UIKit

extension EditProfileViewController {

    enum SectionLayoutKind: CaseIterable {
        case name
        case introduction
        case header
//        case icon
        case socialLink

        var headerTitle: String {
            switch self {
                case .name:
                    return "ネーム"

                case .introduction:
                    return "自己紹介文"

                case .header:
                    return "ヘッダー画像"

//                case .icon:
//                    return "アイコン"

                case .socialLink:
                    return "SNSリンク"

                default:
                    return ""

            }
        }

        var headerIdentifer: String {
            switch self {
                case .name, .introduction, .header, .socialLink:
                    return TitleSupplementaryView.className

                default:
                    return ""
            }
        }

        var initialItems: [ItemKind] {
            switch self {
                case .name:
                    return [.name]

                case .introduction:
                    return [.introduction]

                case .header:
                    return [.noImage]

//                case .icon:
//                    return [.icon(.)]

                default:
                    return []
            }
        }
    }

    enum ItemKind: Hashable {
        case name
        case introduction
        case header(ImageDataKind)
        case noImage
//        case icon(ImageDataKind)
        case socialLink(FIDocument.User.SocialLinkType)
        case error(ValidationError)

        var isErrorItem: Bool {
            if case .error = self {
                return true

            } else {
                return false

            }
        }
    }

}

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
//        case icon
        case socialLink
        case header

        var headerTitle: String {
            switch self {
                case .name:
                    return "ネーム"

                case .introduction:
                    return "自己紹介文"

                case .socialLink:
                    return "SNSリンク"

                case .header:
                    return "ヘッダー画像"

//                case .icon:
//                    return "アイコン"
            }
        }

        var headerIdentifer: String {
            switch self {
                case .name, .introduction, .header, .socialLink:
                    return TitleSupplementaryView.className
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

                case .socialLink:
                    return FIDocument.User.SocialLinkType.allCases.map {
                        ItemKind.socialLink(.init(linkType: $0, link: ""))
                    }
            }
        }
    }

    enum ItemKind: Hashable {
        case name
        case introduction
        case header(ImageDataKind)
        case noImage
//        case icon(ImageDataKind)
        case socialLink(FIDocument.User.SocialLink)
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

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
        case socialLink
        case icon
        case header

        var headerTitle: String {
            switch self {
                case .name:
                    return "ネーム"

                case .introduction:
                    return "自己紹介文"

                case .socialLink:
                    return "SNSリンク"

                case .icon:
                    return "アイコン"

                case .header:
                    return "ヘッダー画像"

            }
        }

        var headerIdentifer: String {
            switch self {
                case .name, .introduction, .header, .icon, .socialLink:
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

                case .icon:
                    return [.icon(.init(imageType: .icon))]

                case .socialLink:
                    return FIDocument.User.SocialLinkType.allCases.map { .socialLink($0) }
            }
        }
    }

    enum ItemKind: Hashable {
        case name
        case introduction
        case header(CrudableImage<FIDocument.User>)
        case noImage
        case icon(CrudableImage<FIDocument.User>)
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

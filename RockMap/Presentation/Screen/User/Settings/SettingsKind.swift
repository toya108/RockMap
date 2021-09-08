//
//  SettingsKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/31.
//

import Foundation
import UIKit

extension SettingsViewController {

    enum SectionKind: CaseIterable {
        case account
        case aboutThisApp

        var headerTitle: String {
            switch self {
                case .account:
                    return "アカウント"

                case .aboutThisApp:
                    return "このアプリについて"

            }
        }

        var headerIdentifer: String {
            switch self {
                case .account, .aboutThisApp:
                    return TitleSupplementaryView.className
            }
        }

        var initialItems: [ItemKind] {
            switch self {
                case .account:
                    return [.account]

                case .aboutThisApp:
                    return [.privacyPolicy, .terms, .review]
            }
        }
    }

    enum ItemKind: Hashable {
        case account

        case privacyPolicy
        case terms
        case review

        var iconImage: UIImage {
            switch self {
                case .account:
                    return UIImage.SystemImages.personCircle

                case .privacyPolicy:
                    return UIImage.SystemImages.checkmarkShield

                case .terms:
                    return UIImage.SystemImages.docPlaintext

                case .review:
                    return UIImage.SystemImages.starCircle
            }
        }

        var title: String {
            switch self {
                case .account:
                    return "アカウント"

                case .privacyPolicy:
                    return "プライバシーポリシー"

                case .terms:
                    return "利用規約"

                case .review:
                    return "レビュー"
            }
        }
    }

}

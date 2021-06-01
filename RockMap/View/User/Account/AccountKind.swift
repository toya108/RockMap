//
//  AccountKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/06/01.
//

import Foundation
import UIKit

extension AccountViewController {

    enum SectionKind: CaseIterable {
        case userInfo
        case auth

        var headerTitle: String {
            switch self {
                case .userInfo:
                    return "ユーザ情報"

                case .auth:
                    return "アカウント管理"

            }
        }

        var headerIdentifer: String {
            switch self {
                case .userInfo, .auth:
                    return TitleSupplementaryView.className
            }
        }

        var initialItems: [ItemKind] {
            switch self {
                case .userInfo:
                    return [.id, .authProvider]

                case .auth:
                    return AuthManager.shared.isLoggedIn
                        ? [.loginOrLogout, .deleteUser]
                        : [.loginOrLogout]
            }
        }
    }

    enum ItemKind: Hashable {
        case id
        case authProvider

        case loginOrLogout
        case deleteUser

        var title: String {
            switch self {
                case .id:
                    return "ID"

                case .authProvider:
                    return "ログイン方法"

                case .loginOrLogout:
                    return AuthManager.shared.isLoggedIn ? "ログアウト" : "ログイン"

                case .deleteUser:
                    return "アカウントの削除"
            }
        }

        var secondaryText: String? {
            switch self {
                case .id:
                    return AuthManager.shared.uid

                case .authProvider:
                    return AuthManager.shared.currentUser?.providerID ?? "-"

                default:
                    return nil
            }
        }

        var tapEnabled: Bool {
            switch self {
                case .id, .authProvider:
                    return false

                case .loginOrLogout, .deleteUser:
                    return true
            }
        }
    }

}

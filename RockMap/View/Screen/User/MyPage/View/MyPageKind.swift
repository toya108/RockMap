//
//  MyPageKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import Foundation
import UIKit

extension MyPageViewController {

    enum SectionKind: CaseIterable {
        case headerImage
        case user
        case socialLink
        case introduction
        case climbedNumber
        case recentClimbedCourses
        case registered

        var headerTitle: String {
            switch self {
                case .climbedNumber:
                    return "完登数"

                case .recentClimbedCourses:
                    return "最近登った課題"

                case .registered:
                    return "登録した岩/課題"

                default:
                    return ""

            }
        }

        var headerIdentifer: String {
            switch self {
                case .climbedNumber, .recentClimbedCourses, .registered:
                    return TitleSupplementaryView.className

                default:
                    return ""

            }
        }

        var initialItems: [ItemKind] {
            switch self {
                case .headerImage:
                    return [.headerImage]

                case .user:
                    return [.user]

                case .socialLink:
                    return Entity.User.SocialLinkType.allCases.map { .socialLink($0) }

                case .introduction:
                    return [.introduction]

                case .climbedNumber:
                    return [.climbedNumber]

                case .registered:
                    return [.registeredRock(.rock), .registeredCourse(.course)]

                default:
                    return []
            }
        }
    }

    enum ItemKind: Hashable {
        case headerImage
        case user
        case socialLink(Entity.User.SocialLinkType)
        case introduction
        case climbedNumber
        case noCourse
        case climbedCourse(FIDocument.Course)
        case registeredRock(RegisteredKind)
        case registeredCourse(RegisteredKind)

        enum RegisteredKind {
            case rock, course

            var cellTitle: String {
                switch self {
                    case .rock:
                        return "登録した岩"
                    case .course:
                        return "登録した課題"
                }
            }

            var iconImage: UIImage {
                switch self {
                    case .rock:
                        return UIImage.AssetsImages.rockFill
                    case .course:
                        return UIImage.SystemImages.docPlaintextFill
                }

            }
        }
    }

}

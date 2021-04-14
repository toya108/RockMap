//
//  CourseDetailKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit

extension CourseDetailViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case headerImage
        case buttons
        case registeredUser
        case climbedNumber
        case info
        case desc
        case images
        
        var headerTitle: String {
            switch self {
                case .climbedNumber:
                    return "完登者数"

                case .info:
                    return "基本情報"

                case .desc:
                    return "詳細"

                case .images:
                    return "画像"

                default:
                    return ""

            }
        }
        
        var headerIdentifer: String {
            switch self {
                case .climbedNumber, .info, .images, .desc:
                    return TitleSupplementaryView.className
                
                default:
                    return ""

            }
        }
        
        var initialItems: [ItemKind] {
            switch self {
                case .buttons:
                    return [.buttons]

                case .registeredUser:
                    return [.registeredUser]

                case .climbedNumber:
                    return [.climbedNumber]

                default:
                    return []
                
            }
        }
    }
    
    enum ItemKind: Hashable {
        case headerImage(StorageManager.Reference)
        case buttons
        case registeredUser
        case climbedNumber
        case shape(Set<FIDocument.Course.Shape>)
        case desc(String)
        case image(StorageManager.Reference)
    }
    
}

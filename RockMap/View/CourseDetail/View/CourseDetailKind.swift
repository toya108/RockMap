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
        
        var headerTitle: String {
            switch self {
                case .climbedNumber:
                    return "完登者数"

                case .info:
                    return "基本情報"

                default:
                    return ""

            }
        }
        
        var headerIdentifer: String {
            switch self {
                case .climbedNumber, .info:
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
    }
    
}

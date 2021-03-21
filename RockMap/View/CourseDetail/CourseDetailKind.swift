//
//  CourseDetailKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit

extension CourseDetailViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case headerImages
        case buttons
        case registeredUser
        case climbedNumber
        
        var headerTitle: String {
            return "完登者数"
        }
        
        var headerIdentifer: String {
            switch self {
            case .climbedNumber:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
            
        }
        
        var initialItems: [ItemKind] {
            switch self {
            case .buttons:
                return [.buttons]
                
            case .climbedNumber:
                return [.climbedNumber]
                
            default:
                return []
                
            }
        }
    }
    
    enum ItemKind: Hashable {
        case headerImages(StorageManager.Reference)
        case buttons
        case registeredUser(CourseDetailViewModel.UserCellStructure)
        case climbedNumber
    }
    
}

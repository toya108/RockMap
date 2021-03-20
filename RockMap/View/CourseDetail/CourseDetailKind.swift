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
        
        var headerTitle: String {
            return ""
        }
        
        var headerIdentifer: String {
            return ""
        }
        
        var initialItems: [ItemKind] {
            switch self {
            case .buttons:
                return [.buttons]
                
            default:
                return []
                
            }
        }
    }
    
    enum ItemKind: Hashable {
        case headerImages(StorageManager.Reference)
        case buttons
        case registeredUser(CourseDetailViewModel.UserCellStructure)
    }
    
}

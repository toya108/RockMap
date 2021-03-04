//
//  RockDetailKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import UIKit

extension RockDetailViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case headerImages
        case registeredUser
        case desc
        case map
        case courses
        
        var headerTitle: String {
            switch self {
            case .desc:
                return "岩の説明"
                
            case .map:
                return "岩の位置"
            
            case .courses:
                return "課題一覧"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
            case .desc, .map, .courses:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
    }
    
    enum ItemKind: Hashable {
        case headerImages(referece: StorageManager.Reference)
        case registeredUser(user: FIDocument.User)
        case desc(String)
        case map(RockDetailViewModel.RockLocation)
        // course section
        case courses
        case nocourse
    }
    
}

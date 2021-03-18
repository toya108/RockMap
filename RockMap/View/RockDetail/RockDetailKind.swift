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
        case info
        case desc
        case courses
        case map
        
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
        case season(Set<FIDocument.Rock.Season>)
        case lithology(FIDocument.Rock.Lithology)
        case map(LocationManager.LocationStructure)
        // course section
        case courses(FIDocument.Course)
        case nocourse
    }
    
}

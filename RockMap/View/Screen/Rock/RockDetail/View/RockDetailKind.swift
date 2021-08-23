//
//  RockDetailKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import UIKit

extension RockDetailViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case header
        case title
        case registeredUser
        case info
        case courses
        case desc
        case map
        case images
        
        var headerTitle: String {
            switch self {
            case .desc:
                return "詳細"
                
            case .map:
                return "岩の位置"

            case .info:
                return "基本情報"
            
            case .courses:
                return "課題一覧"

            case .images:
                return "画像"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
                case .desc, .map, .info, .courses, .images:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
    }
    
    enum ItemKind: Hashable {
        case header(ImageLoadable)
        case title(String)
        case registeredUser(user: Entity.User)
        case desc(String)
        case season(Set<FIDocument.Rock.Season>)
        case lithology(FIDocument.Rock.Lithology)
        case containGrade([FIDocument.Course.Grade: Int])
        case map(LocationManager.LocationStructure)
        case courses(FIDocument.Course)
        case nocourse
        case image(ImageLoadable)
        case noImage
    }
    
}

//
//  RockConfirmKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/12.
//

import Foundation

extension RockConfirmViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case name
        case desc
        case season
        case lithology
        case location
        case header
        case images
        case register
        
        var headerTitle: String {
            switch self {
            case .name:
                return "岩名"
                
            case .desc:
                return "詳細"
                
            case .season:
                return "シーズン"
                
            case .lithology:
                return "岩質"
                
            case .location:
                return "住所"

            case .header:
                return "ヘッダー画像"

            case .images:
                return "画像"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
                case .name, .desc, .season, .lithology, .location, .header, .images:
                    return TitleSupplementaryView.className

                default:
                    return ""
            }
        }

    }
    
    enum ItemKind: Hashable {
        case name(String)
        case desc(String)
        case season(Set<FIDocument.Rock.Season>)
        case lithology(FIDocument.Rock.Lithology)
        case location(LocationManager.LocationStructure)
        case header(CrudableImage)
        case images(CrudableImage)
        case register
    }
    
}

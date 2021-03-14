//
//  File.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit
import CoreLocation

extension RockRegisterViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case name
        case desc
        case location
        case season
        case lithology
        case images
        case confirmation
        
        var headerTitle: String {
            switch self {
            case .name:
                return "岩名"
                
            case .desc:
                return "岩の説明"
                
            case .location:
                return "住所"
                
            case .season:
                return "シーズン"
                
            case .lithology:
                return "岩質"
                
            case .images:
                return "画像をアップロード"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
            case .name, .desc, .location, .season, .lithology, .images:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
        
        var initalItems: [ItemKind] {
            switch self {
            case .name:
                return [.name]
                
            case .desc:
                return [.desc]

            case .images:
                return [.noImage]
                
            case .confirmation:
                return [.confirmation]
                
            default:
                return []
            }
        }
    }
    
    enum ItemKind: Hashable {
        case name
        case desc
        case location(LocationManager.LocationStructure)
        case season(season: FIDocument.Rock.Season, isSelecting: Bool)
        case lithology(FIDocument.Rock.Lithology)
        case noImage
        case images(IdentifiableData)
        case confirmation
        case error(String)
        
        var isErrorItem: Bool {
            if case .error = self {
                return true
                
            } else {
                return false
                
            }
        }
    }
    
}

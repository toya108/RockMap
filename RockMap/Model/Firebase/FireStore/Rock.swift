//
//  Rock.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/15.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

extension FIDocument {
    struct Rock: FIDocumentProtocol {
        typealias Collection = FINameSpace.Rocks
        typealias Parent = FIDocument.User
        
        var id: String
        var createdAt: Date
        var updatedAt: Date?
        var parentPath: String
        var name: String
        var address: String
        var prefecture: String
        var location: GeoPoint
        var seasons: Set<Season>
        var lithology: Lithology
        var desc: String
        var registeredUserId: String
        
        init(
            id: String,
            createdAt: Date,
            updatedAt: Date?,
            parentPath: String,
            name: String,
            address: String,
            prefecture: String,
            location: GeoPoint,
            seasons: Set<Season>,
            lithology: Lithology,
            desc: String ,
            registeredUserId: String
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.parentPath = parentPath
            self.name = name
            self.address = address
            self.prefecture = prefecture
            self.location = location
            self.seasons = seasons
            self.lithology = lithology
            self.desc = desc
            self.registeredUserId = registeredUserId
        }
        
        enum Season: String, CaseIterable, Codable {
            case spring, summer, autumn, winter
            
            var iconImage: UIImage {
                switch self {
                case .spring:
                    return UIImage.AssetsImages.spring
                    
                case .summer:
                    return UIImage.AssetsImages.summer
                    
                case .autumn:
                    return UIImage.AssetsImages.autumn
                    
                case .winter:
                    return UIImage.AssetsImages.winter
                }
            }
            
            var name: String {
                switch self {
                case .spring:
                    return "春"
                    
                case .summer:
                    return "夏"
                    
                case .autumn:
                    return "秋"
                    
                case .winter:
                    return "冬"
                    
                }
            }
        }
        
        enum Lithology: String, CaseIterable, Codable {
            case unKnown, granite, andesite, chert, limestone, tuff, sandstone
            
            var name: String {
                switch self {
                case .unKnown:
                    return "不明"
                    
                case .granite:
                    return "花崗岩"
                    
                case .andesite:
                    return "安山岩"
                    
                case .chert:
                    return "チャート"
                    
                case .limestone:
                    return "石灰岩"
                    
                case .tuff:
                    return "凝灰岩"
                    
                case .sandstone:
                    return "砂岩"
                    
                }
            }
        }
    }
}

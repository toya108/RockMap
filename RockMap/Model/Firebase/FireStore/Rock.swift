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
        
        var id: String
        var createdAt: Date
        var updatedAt: Date?
        var name: String
        var address: String
        var location: GeoPoint
        var seasons: Set<Season>
        var lithology: Lithology
        var desc: String
        var registeredUserId: String
        
        init(
            id: String = UUID().uuidString,
            createdAt: Date = Date(),
            updatedAt: Date = Date(),
            name: String = "",
            address: String = "",
            location: GeoPoint = .init(latitude: 0, longitude: 0),
            seasons: Set<Season> = [],
            lithology: Lithology = .unKnown,
            desc: String = "",
            registeredUserId: String = ""
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.name = name
            self.address = address
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

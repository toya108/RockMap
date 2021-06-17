//
//  Rock.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/15.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

extension FIDocument {

    struct Rock: FIDocumentProtocol, UserRegisterableDocumentProtocol {

        typealias Collection = FINameSpace.Rocks

        var id: String = UUID().uuidString
        var createdAt: Date = Date()
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
        var headerUrl: URL?
        var imageUrls: [URL] = []
    }

}

extension FIDocument.Rock {

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

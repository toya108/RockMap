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
        var name: String
        var address: String
        var location: GeoPoint
        var desc: String
        var registeredUserId: String
        var courseId: [String]
        var registeredAt: Date?
        
        init(
            id: String = UUID().uuidString,
            name: String = "",
            address: String = "",
            location: GeoPoint = .init(latitude: 0, longitude: 0),
            desc: String = "",
            registeredUserId: String = "",
            courseId: [String] = [],
            registeredAt: Date? = Date()
        ) {
            self.id = id
            self.name = name
            self.address = address
            self.location = location
            self.desc = desc
            self.registeredUserId = registeredUserId
            self.courseId = courseId
            self.registeredAt = registeredAt
        }
    }
}

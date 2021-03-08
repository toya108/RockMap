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
        var desc: String
        var registeredUserId: String
        var courses: [Course]
        
        init(
            id: String = UUID().uuidString,
            createdAt: Date = Date(),
            updatedAt: Date = Date(),
            name: String = "",
            address: String = "",
            location: GeoPoint = .init(latitude: 0, longitude: 0),
            desc: String = "",
            registeredUserId: String = "",
            courses: [Course] = []
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.name = name
            self.address = address
            self.location = location
            self.desc = desc
            self.registeredUserId = registeredUserId
            self.courses = courses
        }
    }
}

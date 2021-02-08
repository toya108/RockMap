//
//  Rocks.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/15.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

extension FIDocument {
    struct Rocks: FIDocumentProtocol {
        
        typealias Collection = FINameSpace.Rocks
        
        var name: String
        var address: String
        var location: GeoPoint
        var desc: String
        var registeredUserId: String
        var courseId: [String]
        
        init(
            name: String = "",
            address: String = "",
            location: GeoPoint = .init(latitude: 0, longitude: 0),
            desc: String = "",
            registeredUserId: String = "",
            courseId: [String] = []
        ) {
            self.name = name
            self.address = address
            self.location = location
            self.desc = desc
            self.registeredUserId = registeredUserId
            self.courseId = courseId
        }
    }
}

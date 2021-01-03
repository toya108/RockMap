//
//  Rocks.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/15.
//

import FirebaseFirestore

extension FIDocument {
    struct Rocks: FIDocumentProtocol {
        
        typealias Collection = FINameSpace.Rocks
        
        var name: String
        var imageIds: [String]
        var address: String
        var location: GeoPoint
        var desc: String
        var registeredUserId: String
        var courseId: [String]
    }
}

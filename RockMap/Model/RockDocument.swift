//
//  Rock.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/26.
//

import FirebaseFirestore

struct RockDocument: Decodable {
    var name: String
    var desc: String
    var point: FirebaseFirestore.GeoPoint
    
    static let collectionName = "rock"
}

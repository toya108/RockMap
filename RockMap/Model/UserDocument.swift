//
//  User.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import FirebaseFirestore

struct UserDocument: Decodable {
    
    var id: Int
    var name: String
    var email: String
    var iconImage: String?
    
    static let collectionName = "user"
}

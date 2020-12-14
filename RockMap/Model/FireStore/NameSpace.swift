//
//  NameSpace.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/29.
//

import FirebaseFirestore

struct FICollection {
    struct Users: FICollectionProtocol {
        static var name: String { "users" }
    }
    
    struct Rocks {}
}

struct FIDocument {}

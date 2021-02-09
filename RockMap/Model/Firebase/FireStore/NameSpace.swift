//
//  NameSpace.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/29.
//

import FirebaseFirestore

struct FINameSpace {
    struct Users: FINameSpaceProtocol {
        static var name: String { "users" }
    }
    struct Rocks: FINameSpaceProtocol {
        static var name: String { "rocks" }
    }
    struct Cource: FINameSpaceProtocol {
        static var name: String { "cources" }
    }
}

struct FIDocument {}

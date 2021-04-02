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
    struct Course: FINameSpaceProtocol {
        static var name: String { "courses" }
    }
    struct Climbed: FINameSpaceProtocol {
        static var name: String { "climbed" }
    }
    struct TotalClimbedNumber: FINameSpaceProtocol {
        static var name: String { "totalClimbedNumber" }
    }
}

struct FIDocument {}

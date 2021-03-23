//
//  User.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import Foundation
import FirebaseFirestoreSwift

extension FIDocument {
    struct User: FIDocumentProtocol {
        
        typealias Collection = FINameSpace.Users
        
        var id: String
        var createdAt: Date
        var updatedAt: Date?
        var parentPath: String = ""
        var name: String
        var email: String?
        var photoURL: URL?
        var createdRock: [Rock]
        var createdCources: [Course]
        
        
        var isRoot: Bool { true }
    }
}

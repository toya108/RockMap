//
//  User.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension FIDocument {
    struct User: FIDocumentProtocol {
        
        typealias Collection = FINameSpace.Users
        
        var id: String = UUID().uuidString
        var createdAt: Date = Date()
        var updatedAt: Date?
        var parentPath: String = ""
        var name: String
        var email: String?
        var photoURL: URL?
        var createdRock: [DocumentReference] = []
        var createdCources: [DocumentReference] = []
        
        var isRoot: Bool { true }
    }
}

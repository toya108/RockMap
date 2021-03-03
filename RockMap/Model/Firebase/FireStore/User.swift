//
//  User.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import Foundation

extension FIDocument {
    struct User: FIDocumentProtocol {
        typealias Collection = FINameSpace.Users
        
        var uid: String = ""
        var name: String = ""
        var email: String?
        var photoURL: URL?
        var creationDate: Date?
    }
}

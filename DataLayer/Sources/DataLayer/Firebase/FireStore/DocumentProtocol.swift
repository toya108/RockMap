//
//  DocumentProtocol.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import Foundation
import FirebaseFirestore
import Combine

typealias DocumentRef = DocumentReference

protocol DocumentProtocol: Codable {
    var collection: CollectionProtocol.Type { get }
    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date? { get set }
    var parentPath: String { get set }
}

protocol UserRegisterableDocumentProtocol: Codable, Hashable {
    var registeredUserId: String { get set }
}

enum FirestoreError: Error {
    case nilResultError
}

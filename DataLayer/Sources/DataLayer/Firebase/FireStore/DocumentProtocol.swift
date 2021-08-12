//
//  DocumentProtocol.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import Foundation
import FirebaseFirestore
import Combine

public typealias FSDocument = DocumentReference

public protocol DocumentProtocol: Codable {
    var collection: CollectionProtocol.Type { get }
    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date? { get set }
    var parentPath: String { get set }
}

extension DocumentProtocol {

    static func initialize(json: [String: Any]) -> Self? {
        do {
            return try FirestoreManager.decoder.decode(self, from: json)
        } catch {
            print("type:\(Self.self) のdecodeに失敗しました。reason: \(error.localizedDescription)")
            assertionFailure()
            return nil
        }
    }
    
}

protocol UserRegisterableDocumentProtocol: Codable, Hashable {
    var registeredUserId: String { get set }
}

enum FirestoreError: Error {
    case nilResultError
}

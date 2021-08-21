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
public typealias FSListenerRegistration = ListenerRegistration

public protocol DocumentProtocol: Codable {
    var collection: CollectionProtocol.Type { get }
    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date? { get set }
    var parentPath: String { get set }
}

extension DocumentProtocol {

    var reference: DocumentReference {
        if collection.isRoot {
            return FirestoreManager.db
                .collection(collection.name)
                .document(id)
        } else {
            return FirestoreManager.db
                .document(parentPath)
                .collection(collection.name)
                .document(id)
        }
    }

    static func initialize(json: [String: Any]) -> Self? {
        do {
            return try FirestoreManager.decoder.decode(self, from: json)
        } catch {
            print("type:\(Self.self) のdecodeに失敗しました。reason: \(error.localizedDescription)")
            assertionFailure()
            return nil
        }
    }

    var dictionary: [String: Any] {
        do {
            let dictionary = try FirestoreManager.encoder.encode(self)
            return dictionary
        } catch {
            assertionFailure("encodeに失敗しました。\(error.localizedDescription)")
            return [:]
        }
    }

    func makedictionary(shouldExcludeEmpty: Bool = false) throws -> [String: Any] {
        let dictionaly = try FirestoreManager.encoder.encode(self)

        if shouldExcludeEmpty {
            return dictionaly.makeEmptyExcludedDictionary()
        } else {
            return dictionaly
        }
    }
    
}

protocol UserRegisterableDocumentProtocol: Codable, Hashable {
    var registeredUserId: String { get set }
}

enum FirestoreError: Error {
    case nilResultError
}

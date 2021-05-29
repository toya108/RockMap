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

protocol FINameSpaceProtocol {
    static var name: String { get }
}

protocol FIDocumentProtocol: Codable, Hashable {
    associatedtype Collection: FINameSpaceProtocol
    
    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date? { get set }
    var parentPath: String { get set }
    
    var isRoot: Bool { get }
}

extension FIDocumentProtocol {

    var isRoot: Bool { false }

    func makeDocumentReference() -> DocumentReference {
        if isRoot {
            return FirestoreManager.db
                .collection(Self.colletionName)
                .document(id)
        } else {
            return FirestoreManager.db
                .document(parentPath)
                .collection(Self.colletionName)
                .document(id)
        }
    }

    func makeCollectionReference() -> CollectionReference {
        if isRoot {
            return FirestoreManager.db
                .collection(Self.colletionName)
        } else {
            return FirestoreManager.db
                .document(parentPath)
                .collection(Self.colletionName)
        }
    }

    static var colletionName: String {
        return Collection.name
    }
    
    static func initializeDocument(json: [String: Any]) -> Self? {
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

enum FirestoreError: Error {
    case nilResultError
}

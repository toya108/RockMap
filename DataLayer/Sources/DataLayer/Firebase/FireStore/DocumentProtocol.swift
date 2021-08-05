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
    static var isRoot: Bool { get }
}

extension FINameSpaceProtocol {
    static var isRoot: Bool { false }
}

protocol FIDocumentProtocol: Codable, Hashable {
    associatedtype Collection: FINameSpaceProtocol

    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date? { get set }
    var parentPath: String { get set }
}

protocol UserRegisterableDocumentProtocol: Codable, Hashable {
    var registeredUserId: String { get set }
}

extension FIDocumentProtocol {

    func makeDocumentReference() -> DocumentReference {
        if Collection.isRoot {
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

        return shouldExcludeEmpty
            ? dictionaly.makeEmptyExcludedDictionary()
            : dictionaly
    }
}

enum FirestoreError: Error {
    case nilResultError
}

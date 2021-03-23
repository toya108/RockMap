//
//  DocumentProtocol.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import Foundation

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
    
    static var colletionName: String {
        return Collection.name
    }
    
    static func makeParentPath(parentPath: String? = nil, parentCollection: String, documentId: String) -> String {
        if let parentPath = parentPath {
            return [parentPath, parentCollection, documentId].joined(separator: "/")
            
        } else {
            return [parentCollection, documentId].joined(separator: "/")
            
        }
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
}

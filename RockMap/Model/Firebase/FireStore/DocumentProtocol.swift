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

protocol FIDocumentProtocol: Codable {
    associatedtype Collection: FINameSpaceProtocol
}

extension FIDocumentProtocol {
    static var colletionName: String {
        return Collection.name
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

//
//  StorageManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/17.
//

import FirebaseStorage
import Combine

struct StorageManager {
    
    typealias Reference = StorageReference
    
    static let reference = Storage.storage().reference()
    
    static func makeReference(
        parent: FINameSpaceProtocol.Type,
        child: String
    ) -> StorageReference {
        Self.reference.child(parent.name).child(child)
    }
    
    static func getAllReference(
        reference: StorageReference,
        completion: @escaping (Result<[Reference], Error>) -> Void
    ) {
        reference.listAll { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(result.items))
        }
    }

    static func getHeaderReference(
        reference: StorageReference,
        completion: @escaping (Result<Reference, Error>) -> Void
    ) {
        let headerReference = reference.child(ImageType.header.typeName)

        headerReference.list(withMaxResults: 1) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(result.items.first ?? .init()))
        }
    }
}

//
//  FireStoreManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import FirebaseFirestore

final class FirestoreManager {
    static let db = Firestore.firestore()
    static let encoder = Firestore.Encoder()
    
    static func set<T: FIDocumentProtocol>(key: String, _ document: T, completion: ((Result<Void, Error>) -> Void)? = nil) {
        db.collection(T.colletionName).document(key).setData(document.dictionary) { error in
            
            guard let completion = completion else { return }
            
            if let error = error {
                completion(.failure(error))
            }
            
            completion(.success(()))
        }
    }
}

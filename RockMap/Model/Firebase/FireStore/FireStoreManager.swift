//
//  FireStoreManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import FirebaseFirestore

struct FirestoreManager {
    static let db = Firestore.firestore()
    static let encoder = Firestore.Encoder()
    
    static func set<T: FIDocumentProtocol>(key: String = "", _ newDocument: T, completion: ((Result<Void, Error>) -> Void)? = nil) {
        
        let document = key.isEmpty ? db.collection(T.colletionName).document() : db.collection(T.colletionName).document(key)
        
        document.setData(newDocument.dictionary) { error in
            
            guard let completion = completion else { return }
            
            if let error = error {
                completion(.failure(error))
            }
            
            completion(.success(()))
        }
    }
}

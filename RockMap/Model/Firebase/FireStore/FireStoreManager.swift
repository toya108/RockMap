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
    static let decoder = Firestore.Decoder()
    
    static func set<T: FIDocumentProtocol>(
        key: String,
        _ newDocument: T,
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {
        
        let collection = db.collection(T.colletionName)
        let document = key.isEmpty ? collection.document() : collection.document(key)
        
        document.setData(newDocument.dictionary) { error in
            
            guard let completion = completion else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }

    static func set<T: FIDocumentProtocol>(
        parentPath: String,
        documentId: String,
        document: T,
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {

        let collectionPath = [parentPath, T.colletionName].joined(separator: "/")
        let documentRef = db.collection(collectionPath).document(documentId)

        documentRef.setData(document.dictionary) { error in

            guard let completion = completion else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }
    }
    
    static func fetchAllDocuments<T: FIDocumentProtocol>(completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(T.colletionName).getDocuments { snap, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let documents = snap?.documents.compactMap { T.initializeDocument(json: $0.data()) } ?? []
            completion(.success(documents))
        }
    }
    
    static func fetchById<T: FIDocumentProtocol>(id: String, completion: @escaping (Result<T?, Error>) -> Void) {
        
        if id.isEmpty { return }
        
        db.collection(T.colletionName).document(id).getDocument { snap, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let document = T.initializeDocument(json: snap?.data() ?? [:])
            completion(.success(document))
        }
    }

    static func makeParentPath<T: FIDocumentProtocol>(parent: T) -> String {
        return [parent.parentPath, T.colletionName, parent.id].joined(separator: "/")
    }
}

enum StoreUploadState {
    case stanby
    case loading
    case finish
    case failure(Error)
}

//
//  Query+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/10.
//

import Foundation

import FirebaseFirestore
import Combine

extension Query {

    func getDocuments<T: FIDocumentProtocol>(_ type: T.Type) -> AnyPublisher<[T], Error> {

        Deferred {
            Future<[T], Error> { [weak self] promise in

                guard let self = self else { return }

                self.getDocuments { snapshot, error in

                    if let error = error {
                        promise(.failure(error))
                    }

                    guard
                        let snapshot = snapshot
                    else {
                        promise(.failure(FirestoreError.nilResultError))
                        return
                    }

                    let docs = snapshot.documents.compactMap {
                        T.initializeDocument(json: $0.data())
                    }
                    promise(.success(docs))
                }
            }
        }.eraseToAnyPublisher()
        
    }
}

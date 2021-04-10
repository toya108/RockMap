//
//  Document+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/10.
//

import FirebaseFirestore
import Combine

extension DocumentReference {

    func setData<T: FIDocumentProtocol>(
        from data: T
    ) -> AnyPublisher<Void, Error> {

        Deferred {
            Future<Void, Error> { [weak self] promise in

                guard let self = self else { return }

                do {
                    try self.setData(data.makedictionary()) { error in

                        if let error = error {
                            promise(.failure(error))
                            return
                        }

                        promise(.success(()))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func getDocument<T: FIDocumentProtocol>(
        _ type: T.Type
    ) -> AnyPublisher<T?, Error> {

        Deferred {
            Future<T?, Error> { [weak self] promise in

                guard let self = self else { return }

                self.getDocument { snapshot, error in
                    
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard
                        let snapshot = snapshot,
                        let dictionaly = snapshot.data(),
                        let document = T.initializeDocument(json: dictionaly)
                    else {
                        promise(.failure(FirestoreError.nilResultError))
                        return
                    }

                    promise(.success(document))
                }
            }

        }.eraseToAnyPublisher()
    }
}

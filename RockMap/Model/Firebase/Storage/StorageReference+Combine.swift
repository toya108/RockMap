//
//  StorageReference+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/11.
//

import Combine
import FirebaseStorage

extension StorageReference {

    func getReferences() -> AnyPublisher<[StorageReference], Error> {

        Deferred {
            Future<[StorageReference], Error> { [weak self] promise in

                guard let self = self else { return }

                self.listAll { result, error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(result.items))
                }
            }

        }.eraseToAnyPublisher()
    }

    func getPrefixes() -> AnyPublisher<[StorageReference], Error> {

        Deferred {
            Future<[StorageReference], Error> { [weak self] promise in

                guard let self = self else { return }

                self.listAll { result, error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(result.prefixes))
                }
            }

        }.eraseToAnyPublisher()
    }

    func getReference() -> AnyPublisher<StorageReference?, Error> {

        Deferred {
            Future<StorageReference?, Error> { [weak self] promise in

                guard let self = self else { return }

                self.list(withMaxResults: 1) { result, error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard
                        let item = result.items.first
                    else {
                        promise(.failure(FirestoreError.nilResultError))
                        return
                    }

                    promise(.success(item))
                }
            }

        }.eraseToAnyPublisher()
    }

    func delete() -> AnyPublisher<Void, Error> {

        Deferred {
            Future<Void, Error> { [weak self] promise in

                guard let self = self else { return }

                self.delete { error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(()))
                }
            }

        }.eraseToAnyPublisher()
    }

    func getDownloadURL() -> AnyPublisher<URL?, Error> {
        Deferred {
            Future<URL?, Error> { [weak self] promise in

                guard let self = self else { return }

                self.downloadURL { url, error in
                    
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(url))
                }
            }

        }.eraseToAnyPublisher()
    }
}

extension Array where Element: StorageReference {

    func getReferences() -> AnyPublisher<[StorageReference], Error> {
        publisher
            .flatMap { $0.getReferences() }
            .collect()
            .map { $0.flatMap { $0 } }
            .eraseToAnyPublisher()
    }

    func getDownloadUrls() -> AnyPublisher<[URL], Error> {
        publisher
            .flatMap { $0.getDownloadURL() }
            .compactMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
}


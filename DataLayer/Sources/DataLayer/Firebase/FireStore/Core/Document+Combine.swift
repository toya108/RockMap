
import Combine

extension FSDocument {

    func setData<T: DocumentProtocol>(
        from data: T
    ) -> AnyPublisher<EmptyResponse, Error> {

        Deferred {
            Future<EmptyResponse, Error> { [weak self] promise in

                guard let self = self else { return }

                do {
                    try self.setData(data.makedictionary()) { error in

                        if let error = error {
                            promise(.failure(error))
                            return
                        }

                        promise(.success(.init()))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func exists() -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<Bool, Error> { [weak self] promise in

                guard let self = self else { return }

                self.getDocument { snapshot, error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard
                        let snapshot = snapshot
                    else {
                        promise(.failure(FirestoreError.nilResultError))
                        return
                    }

                    promise(.success(snapshot.exists))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getDocument<T: DocumentProtocol>(
        _ type: T.Type
    ) -> AnyPublisher<T, Error> {

        Deferred {
            Future<T, Error> { [weak self] promise in

                guard let self = self else { return }

                self.getDocument { snapshot, error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard
                        let snapshot = snapshot,
                        let dictionaly = snapshot.data(),
                        let document = T.initialize(json: dictionaly)
                    else {
                        promise(.failure(FirestoreError.nilResultError))
                        return
                    }

                    promise(.success(document))
                }
            }

        }.eraseToAnyPublisher()
    }

    func updateData(
        _ fields: [AnyHashable: Any]
    ) -> AnyPublisher<EmptyResponse, Error> {

        Deferred {
            Future<EmptyResponse, Error> { [weak self] promise in

                guard let self = self else { return }

                self.updateData(fields) { error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(.init()))
                }
            }
        }.eraseToAnyPublisher()
    }

    func delete<T: DocumentProtocol>(
        document: T
    ) -> AnyPublisher<T, Error> {

        Deferred {
            Future<T, Error> { [weak self] promise in

                guard let self = self else { return }

                self.delete { error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(document))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func delete() -> AnyPublisher<EmptyResponse, Error> {

        Deferred {
            Future<EmptyResponse, Error> { [weak self] promise in

                guard let self = self else { return }

                self.delete { error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(.init()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Array where Element: FSDocument {

    func getDocuments<T: DocumentProtocol>(
        _ type: T.Type
    ) -> AnyPublisher<[T], Error> {
        publisher
            .flatMap { $0.getDocument(type) }
            .compactMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }

}
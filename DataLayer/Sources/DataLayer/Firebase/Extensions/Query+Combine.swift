import Combine
import FirebaseFirestore

extension FSQuery {
    func getDocuments<T: DocumentProtocol>(
        _ type: T.Type
    ) -> AnyPublisher<[T], Error> {
        Deferred {
            Future<[T], Error> { [weak self] promise in

                guard let self = self else { return }

                self.getDocuments { snapshot, error in

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

                    let docs = snapshot.documents.compactMap {
                        T.initialize(json: $0.data())
                    }
                    promise(.success(docs))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension FSQuery {
    struct Publisher: Combine.Publisher {
        typealias Output = QuerySnapshot
        typealias Failure = Error

        private let query: Query

        init(_ query: Query) {
            self.query = query
        }

        func receive<S>(subscriber: S) where
            S: Subscriber,
            Publisher.Failure == S.Failure,
            Publisher.Output == S.Input {
            let subscription = QuerySnapshot.Subscription(subscriber: subscriber, query: self.query)
            subscriber.receive(subscription: subscription)
        }
    }

    private func publisher() -> AnyPublisher<QuerySnapshot, Error> {
        Publisher(self).eraseToAnyPublisher()
    }

    func listen<T: DocumentProtocol>(
        to type: T.Type
    ) -> AnyPublisher<[T], Error> {
        self.publisher().map {
            $0.documents.map { $0.data() }.compactMap { T.initialize(json: $0) }
        }
        .eraseToAnyPublisher()
    }
}

private extension QuerySnapshot {
    final class Subscription<SubscriberType: Subscriber>: Combine.Subscription where
        SubscriberType.Input == QuerySnapshot,
        SubscriberType.Failure == Error {
        private var registration: ListenerRegistration?

        init(
            subscriber: SubscriberType,
            query: Query
        ) {
            self.registration = query.addSnapshotListener { querySnapshot, error in

                if let error = error {
                    subscriber.receive(completion: .failure(error))
                    return
                }

                guard
                    let querySnapshot = querySnapshot
                else {
                    subscriber.receive(completion: .failure(FirestoreError.nilResultError))
                    return
                }

                _ = subscriber.receive(querySnapshot)
            }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            self.registration?.remove()
            self.registration = nil
        }
    }
}

extension FSQuery {

    func getDocument<T: DocumentProtocol>(_ type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.getDocuments { snapshot, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let snapshot = snapshot
                else {
                    continuation.resume(throwing: FirestoreError.nilResultError)
                    return
                }

                guard
                    let snapDoc = snapshot.documents.first,
                    let doc =  T.initialize(json: snapDoc.data())
                else {
                    continuation.resume(throwing: FirestoreError.nilResultError)
                    return
                }

                continuation.resume(returning: doc)
            }
        }
    }


    func getDocuments<T: DocumentProtocol>(_ type: T.Type) async throws -> [T] {
        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.getDocuments { snapshot, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let snapshot = snapshot
                else {
                    continuation.resume(throwing: FirestoreError.nilResultError)
                    return
                }

                let docs = snapshot.documents.compactMap {
                    T.initialize(json: $0.data())
                }
                continuation.resume(returning: docs)
            }
        }
    }

    func listen<T: DocumentProtocol>(to type: T.Type) async throws -> [T] {

        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.addSnapshotListener { snapshot, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let snapshot = snapshot
                else {
                    continuation.resume(throwing: FirestoreError.nilResultError)
                    return
                }

                let docs = snapshot.documents.compactMap {
                    T.initialize(json: $0.data())
                }
                continuation.resume(returning: docs)
            }
        }
    }
}

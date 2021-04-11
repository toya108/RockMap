//
//  Query+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/10.
//

import FirebaseFirestore
import Combine

extension Query {

    func getDocuments<T: FIDocumentProtocol>(
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
                        T.initializeDocument(json: $0.data())
                    }
                    promise(.success(docs))
                }
            }
        }.eraseToAnyPublisher()
        
    }
}

extension Query {

    struct Publisher: Combine.Publisher {

        typealias Output = QuerySnapshot
        typealias Failure = Error

        private let query: Query

        init(_ query: Query) {
            self.query = query
        }

        func receive<S>(subscriber: S) where S: Subscriber, Publisher.Failure == S.Failure, Publisher.Output == S.Input {
            let subscription = QuerySnapshot.Subscription(subscriber: subscriber, query: query)
            subscriber.receive(subscription: subscription)
        }

    }

    private func publisher() -> AnyPublisher<QuerySnapshot, Error> {
        Publisher(self).eraseToAnyPublisher()
    }

    func publisher<T: FIDocumentProtocol>(
        as type: T.Type
    ) -> AnyPublisher<[T], Error> {
        publisher().map {
            return $0.documents.map { $0.data() }.compactMap { T.initializeDocument(json: $0) }
        }
        .eraseToAnyPublisher()
    }

    static func cancel() {
        
    }
}

extension QuerySnapshot {

    fileprivate final class Subscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == QuerySnapshot, SubscriberType.Failure == Error {

        private var registration: ListenerRegistration?

        init(
            subscriber: SubscriberType,
            query: Query
        ) {

            registration = query.addSnapshotListener { (querySnapshot, error) in

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

        func request(_ demand: Subscribers.Demand) {
            // We do nothing here as we only want to send events when they occur.
            // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
        }

        func cancel() {
            registration?.remove()
            registration = nil
        }
    }
}

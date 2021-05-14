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

    func updateData(
        _ fields: [AnyHashable: Any]
    ) -> AnyPublisher<Void, Error> {
        
        Deferred {
            Future<Void, Error> { [weak self] promise in

                guard let self = self else { return }

                self.updateData(fields) { error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }

    func delete<T: FIDocumentProtocol>(
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
                    StorageManager.deleteReference(T.self, id: document.id)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension DocumentReference {

    struct Publisher: Combine.Publisher {

        typealias Output = DocumentSnapshot
        typealias Failure = Error

        private let documentReference: DocumentReference

        init(_ documentReference: DocumentReference) {
            self.documentReference = documentReference
        }

        func receive<S>(subscriber: S) where S: Subscriber, Publisher.Failure == S.Failure, Publisher.Output == S.Input {
            let subscription = DocumentSnapshot.Subscription(
                subscriber: subscriber,
                documentReference: documentReference
            )
            subscriber.receive(subscription: subscription)
        }
    }

    func publisher() -> AnyPublisher<DocumentSnapshot, Error> {
        Publisher(self).eraseToAnyPublisher()
    }

    func publisher<T: FIDocumentProtocol>(
        as type: T.Type
    ) -> AnyPublisher<T?, Error> {
        publisher()
            .map {
                guard
                    let json = $0.data()
                else {
                    return nil
                }

                return T.initializeDocument(json: json)
            }
            .eraseToAnyPublisher()
    }
}

extension DocumentSnapshot {

    final class Subscription<SubscriberType: Subscriber>: Combine.Subscription where
        SubscriberType.Input == DocumentSnapshot,
        SubscriberType.Failure == Error
    {

        private var registration: ListenerRegistration?

        init(
            subscriber: SubscriberType,
            documentReference: DocumentReference
        ) {
            registration = documentReference.addSnapshotListener { (snapshot, error) in

                if let error = error {
                    subscriber.receive(completion: .failure(error))
                }

                guard
                    let snapshot = snapshot
                else {
                    subscriber.receive(completion: .failure(FirestoreError.nilResultError))
                    return
                }

                _ = subscriber.receive(snapshot)
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

extension Array where Element: DocumentReference {

    func getDocuments<T: FIDocumentProtocol>(
        _ type: T.Type
    ) -> AnyPublisher<[T], Error> {
        publisher
            .flatMap { $0.getDocument(type) }
            .compactMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }

}

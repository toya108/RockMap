import Combine
import FirebaseFirestore

extension WriteBatch {
    func commit() -> AnyPublisher<Void, Error> {
        Deferred {
            Future<Void, Error> { [weak self] promise in

                guard let self = self else { return }

                self.commit { error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension WriteBatch {
    func commit() async throws -> EmptyResponse {
        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.commit { error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: .init())
            }
        }
    }
}


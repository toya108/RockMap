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

    func getReference() -> AnyPublisher<StorageReference, Error> {
        Deferred {
            Future<StorageReference, Error> { [weak self] promise in

                guard let self = self else { return }

                self.list(maxResults: 1) { result, error in

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

    func putData(
        _ uploadData: Data,
        metadata: StorageMetadata = .init()
    ) -> AnyPublisher<EmptyResponse, Error> {
        metadata.cacheControl = "no-cache"

        var task: StorageUploadTask?

        return Deferred {
            Future<EmptyResponse, Error> { [weak self] promise in

                guard let self = self else { return }

                task = self.putData(uploadData, metadata: metadata) { _, error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    promise(.success(.init()))
                }
            }
            .handleEvents(receiveCancel: {
                task?.cancel()
            })
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

    func getImage() -> AnyPublisher<FireStorage.Image, Error> {
        Deferred {
            Future<FireStorage.Image, Error> { [weak self] promise in

                guard let self = self else { return }

                let fullPath = self.fullPath

                self.downloadURL { url, error in

                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let url = url else {
                        promise(.failure(FirestoreError.nilResultError))
                        return
                    }

                    promise(.success(.init(fullPath: fullPath, url: url)))
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
}

extension StorageReference {

    func getReferences() async throws -> [StorageReference] {
        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.listAll { result, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: result.items)
            }
        }

    }

    func getPrefixes() async throws -> [StorageReference] {
        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.listAll { result, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: result.prefixes)
            }
        }
    }

    func getReference() async throws -> StorageReference {
        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.list(maxResults: 1) { result, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let item = result.items.first
                else {
                    continuation.resume(throwing: FirestoreError.nilResultError)
                    return
                }

                continuation.resume(returning: item)
            }
        }
    }


    func putData(
        _ uploadData: Data,
        metadata: StorageMetadata = .init()
    ) async throws -> EmptyResponse {

        metadata.cacheControl = "no-cache"

        return try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.putData(uploadData, metadata: metadata) { _, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: .init())
            }
            .resume()
        }
    }

    func delete() async throws -> EmptyResponse {

        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            self.delete { error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: .init())
            }
        }
    }

    func getImage() async throws -> FireStorage.Image {
        try await withCheckedThrowingContinuation { [weak self] continuation in

            guard let self = self else { return }

            let fullPath = self.fullPath

            self.downloadURL { url, error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let url = url else {
                    continuation.resume(throwing: FirestoreError.nilResultError)
                    return
                }

                continuation.resume(returning: .init(fullPath: fullPath, url: url))
            }
        }
    }
}

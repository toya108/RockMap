import FirebaseStorage

extension Array where Element: StorageReference {
    func getReferences() async throws -> [StorageReference] {

        try await withThrowingTaskGroup(of: [StorageReference].self) { group in

            for reference in self {
                group.addTask {
                    return try await reference.getReferences()
                }
            }

            var references: [StorageReference] = []
            for try await refs in group {
                references.append(contentsOf: refs)
            }
            return references
        }

    }

    func getImages() async throws -> [FireStorage.Image] {

        try await withThrowingTaskGroup(of: FireStorage.Image.self) { group in

            for reference in self {
                group.addTask {
                    return try await reference.getImage()
                }
            }

            var images: [FireStorage.Image] = []
            for try await image in group {
                images.append(image)
            }
            return images
        }

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

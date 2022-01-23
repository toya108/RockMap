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

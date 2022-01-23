import Combine
import FirebaseFirestore

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


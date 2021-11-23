import Combine
import DataLayer
import Foundation
import Resolver

public protocol SetUserUsecaseProtocol {

    func set(
        id: String,
        createdAt: Date,
        displayName: String?,
        photoURL: URL?
    ) async throws

}

public extension Domain.Usecase.User {

    struct Set: SetUserUsecaseProtocol {

        @Injected var repository: AnyRepository<Repositories.User.Set.R>
        @Injected var mapper: Domain.Mapper.User

        public func set(
            id: String,
            createdAt: Date,
            displayName: String?,
            photoURL: URL?
        ) async throws {
            try await self.repository.request(
                parameters: .init(
                    id: id,
                    createdAt: createdAt,
                    displayName: displayName,
                    photoURL: photoURL
                )
            )
        }
    }
}

import Combine
import DataLayer
import Foundation
import Resolver

public extension Domain.Usecase.User {
    struct Set: SetUserUsecaseProtocol {

        @Injected var repository: AnyRepository<Repositories.User.Set.R>
        @Injected var mapper: Domain.Mapper.User

        public func set(user: Domain.Entity.User) async throws {
            try await self.repository.request(
                parameters: .init(user: mapper.reverse(to: user))
            )
        }
    }
}

public protocol SetUserUsecaseProtocol {
    func set(user: Domain.Entity.User) async throws
}

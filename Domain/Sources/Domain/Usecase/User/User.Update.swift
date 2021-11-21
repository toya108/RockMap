import Combine
import DataLayer

public extension Domain.Usecase.User {
    struct Update: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.User.Update.R>
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.User.Update()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(user: Domain.Entity.User) async throws {
            _ = try await self.repository.request(
                parameters: .init(user: self.mapper.reverse(to: user))
            )
            return ()
        }
    }
}

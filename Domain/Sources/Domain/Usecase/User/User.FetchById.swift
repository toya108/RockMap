import Combine
import DataLayer

public extension Domain.Usecase.User {
    struct FetchById: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.User.FetchById.R>
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.User.FetchById()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetchUser(by id: String) async throws -> Domain.Entity.User {
            let document = try await self.repository.request(parameters: .init(id: id))
            return mapper.map(from: document)
        }
    }
}

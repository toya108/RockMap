import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.User {
    struct Delete: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.User.Delete.R>
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.User.Delete()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(id: String) async throws {
            _ = try await self.repository.request(
                parameters: .init(id: id)
            )
        }
    }
}

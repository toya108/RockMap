import Combine
import DataLayer

public extension Domain.Usecase.Rock {
    struct FetchById: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.FetchById.R>
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.FetchById()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by id: String) async throws -> Domain.Entity.Rock {
            let document = try await self.repository.request(parameters: .init(id: id))
            return mapper.map(from: document)
        }
    }
}

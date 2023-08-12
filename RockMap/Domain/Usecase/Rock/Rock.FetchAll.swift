import Combine
import DataLayer

public extension Domain.Usecase.Rock {
    struct FetchAll: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.FetchAll.R>
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.FetchAll()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetchAll() async throws -> [Domain.Entity.Rock] {
            let documents = try await self.repository.request(parameters: .init())
            return documents.map { mapper.map(from: $0) }
        }
    }
}

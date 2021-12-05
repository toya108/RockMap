import Combine
import DataLayer

public extension Domain.Usecase.Rock {
    struct FetchByUserId: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.FetchByUserId.R>
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.FetchByUserId()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by userId: String) async throws -> [Domain.Entity.Rock] {
            let documents = try await self.repository.request(
                parameters: .init(userId: userId)
            )
            return documents.map { mapper.map(from: $0) }
        }
    }
}

import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchByRockId: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.FetchByRockId.R>
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.FetchByRockId()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by rockId: String) async throws -> [Domain.Entity.Course] {
            let documents = try await self.repository.request(
                parameters: .init(rockId: rockId)
            )
            return documents.map { mapper.map(from: $0) }
        }
    }
}

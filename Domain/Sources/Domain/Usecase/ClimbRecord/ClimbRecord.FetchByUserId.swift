import Combine
import DataLayer

public extension Domain.Usecase.ClimbRecord {
    struct FetchByUserId: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.ClimbRecord.FetchByUserId.R>
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.ClimbRecord.FetchByUserId()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by userId: String) async throws -> [Domain.Entity.ClimbRecord] {
            let documents = try await self.repository.request(parameters: .init(userId: userId))
            return documents.map { mapper.map(from: $0) }
        }
    }
}

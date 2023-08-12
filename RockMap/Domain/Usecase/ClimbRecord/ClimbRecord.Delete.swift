import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.ClimbRecord {
    struct Delete: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.ClimbRecord.Delete.R>
        public typealias Mapper = Domain.Mapper.ClimbRecord

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.ClimbRecord.Delete()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(id: String) async throws {
            try await self.repository.request(
                parameters: .init(id: id)
            )
        }
    }
}

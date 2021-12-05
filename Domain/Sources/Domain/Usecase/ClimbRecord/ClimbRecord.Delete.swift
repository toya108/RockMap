import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.ClimbRecord {
    struct Delete: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.ClimbRecord.Delete.R>
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.ClimbRecord.Delete()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(parentPath: String, id: String) async throws {
            try await self.repository.request(
                parameters: .init(parentPath: parentPath, id: id)
            )
        }
    }
}

import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct Delete: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.Delete.R>
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.Delete()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(id: String, parentPath: String) async throws {
            _ = try await self.repository.request(
                parameters: .init(id: id, parentPath: parentPath)
            )
            return ()
        }
    }
}

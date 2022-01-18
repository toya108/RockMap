import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct Search: SearchRockUsecaseProtocol, PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.Search.R>
        public typealias Mapper = Domain.Mapper.Rock

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.Search()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func search(text: String) async throws -> [Domain.Entity.Rock] {
            let documents = try await self.repository.request(
                parameters: .init(text: text)
            )

            return documents.map { mapper.map(from: $0) }
        }
    }
}

public protocol SearchRockUsecaseProtocol {
    func search(text: String) async throws -> [Domain.Entity.Rock]
}

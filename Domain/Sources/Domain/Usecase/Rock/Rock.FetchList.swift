import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct FetchList: FetchRockListUsecaseProtocol, PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.FetchList.R>
        public typealias Mapper = Domain.Mapper.Rock

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.FetchList()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(startAt: Date) async throws -> [Domain.Entity.Rock] {
            let documents = try await self.repository.request(
                parameters: .init(startAt: startAt)
            )

            return documents.map { mapper.map(from: $0) }
        }
    }
}

public protocol FetchRockListUsecaseProtocol {
    func fetch(startAt: Date) async throws -> [Domain.Entity.Rock]
}

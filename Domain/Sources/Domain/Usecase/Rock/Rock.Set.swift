import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct Set: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.Set.R>
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.Set()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(rock: Domain.Entity.Rock) async throws {
            let document = self.mapper.reverse(to: rock)
            _ = try await self.repository.request(
                parameters: .init(rock: document)
            )
            return ()
        }
    }
}

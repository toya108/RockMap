import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct Update: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Rock.Update.R>
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Rock.Update()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(rock: Domain.Entity.Rock) async throws {
            let document = self.mapper.reverse(to: rock)
            _ = try await self.repository.request(
                parameters: .init(rock: document)
            )
            return ()
        }
    }
}

import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchById: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.FetchById.R>
        public typealias Mapper = Domain.Mapper.Course

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.FetchById()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by id: String) async throws -> Domain.Entity.Course {
            let document = try await self.repository.request(parameters: .init(id: id))
            return mapper.map(from: document)

        }
    }
}

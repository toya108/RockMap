import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchByReference: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.FetchByReference.R>
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.FetchByReference()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by reference: String) async throws -> Domain.Entity.Course {
            let document = try await self.repository.request(parameters: .init(reference: reference))
            return mapper.map(from: document)

        }
    }
}

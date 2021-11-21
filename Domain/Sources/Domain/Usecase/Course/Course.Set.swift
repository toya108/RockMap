import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct Set: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.Set.R>
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.Set()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(course: Domain.Entity.Course) async throws {
            let document = self.mapper.reverse(to: course)
            _ = try await self.repository.request(
                parameters: .init(course: document)
            )
            return ()
        }
    }
}

import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchByUserId: PassthroughUsecaseProtocol, FetchCourseUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.FetchByUserId.R>
        public typealias Mapper = Domain.Mapper.Course

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.FetchByUserId()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by userId: String) async throws -> [Domain.Entity.Course] {
            let documents = try await self.repository.request(
                parameters: .init(userId: userId)
            )
            return documents.map { mapper.map(from: $0) }
        }
    }
}

public protocol FetchCourseUsecaseProtocol {
    func fetch(by userId: String) async throws -> [Domain.Entity.Course]
}

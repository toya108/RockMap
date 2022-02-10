import Combine
import DataLayer

public extension Domain.Usecase.ClimbRecord {
    struct FetchByCourseId: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.ClimbRecord.FetchByCourseId.R>
        public typealias Mapper = Domain.Mapper.ClimbRecord

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.ClimbRecord.FetchByCourseId()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by courseId: String) async throws -> [Domain.Entity.ClimbRecord] {
            let documents = try await self.repository.request(parameters: .init(courseId: courseId))
            return documents.map { mapper.map(from: $0) }
        }
    }
}

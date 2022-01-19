import Combine
import DataLayer

public extension Domain.Usecase.ClimbRecord {
    struct Set: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.ClimbRecord.Set.R>
        public typealias Mapper = Domain.Mapper.ClimbRecord

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.ClimbRecord.Set()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(climbRecord: Domain.Entity.ClimbRecord) async throws {
            try await self.repository.request(
                parameters: .init(
                    id: climbRecord.id,
                    registeredUserId: climbRecord.registeredUserId,
                    parentCourseId: climbRecord.parentCourseId,
                    parentCourseReference: climbRecord.parentCourseReference,
                    createdAt: climbRecord.createdAt,
                    updatedAt: climbRecord.updatedAt,
                    parentPath: climbRecord.parentPath,
                    climbedDate: climbRecord.climbedDate,
                    type: climbRecord.type.rawValue
                )
            )
        }
    }
}

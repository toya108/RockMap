import Combine
import DataLayer

public extension Domain.Usecase.ClimbRecord {
    struct Set: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.ClimbRecord.Set
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(climbRecord: Domain.Entity.ClimbRecord) -> AnyPublisher<Void, Error> {
            self.repository.request(
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
            .map { _ in () }
            .eraseToAnyPublisher()
        }
    }
}

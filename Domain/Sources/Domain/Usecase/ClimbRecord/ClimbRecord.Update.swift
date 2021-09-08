import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.ClimbRecord {
    struct Update: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.ClimbRecord.Update
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(
            parentPath: String,
            id: String,
            climbedDate: Date?,
            type: Domain.Entity.ClimbRecord.ClimbedRecordType?
        ) -> AnyPublisher<Void, Error> {
            self.repository.request(
                parameters: .init(
                    parentPath: parentPath,
                    id: id,
                    climbedDate: climbedDate,
                    type: type?.rawValue
                )
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }
    }
}

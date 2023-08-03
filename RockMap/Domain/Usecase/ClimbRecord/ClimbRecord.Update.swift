import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.ClimbRecord {
    struct Update: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.ClimbRecord.Update.R>
        public typealias Mapper = Domain.Mapper.ClimbRecord

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.ClimbRecord.Update()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(
            id: String,
            climbedDate: Date?,
            type: Domain.Entity.ClimbRecord.ClimbedRecordType?
        ) async throws {
            try await self.repository.request(
                parameters: .init(
                    id: id,
                    climbedDate: climbedDate,
                    type: type?.rawValue
                )
            )
        }
    }
}

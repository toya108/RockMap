import DataLayer
import Foundation

public extension Domain.Usecase.Course {
    struct FetchList: FetchCourseListUsecaseProtocol, PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.FetchList.R>
        public typealias Mapper = Domain.Mapper.Course

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.FetchList()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(
            startAt: Date,
            grade: Domain.Entity.Course.Grade?
        ) async throws -> [Domain.Entity.Course] {
            let documents = try await self.repository.request(
                parameters: .init(startAt: startAt, grade: grade?.rawValue ?? "")
            )

            return documents.map { mapper.map(from: $0) }
        }
    }
}

public protocol FetchCourseListUsecaseProtocol {
    func fetch(
        startAt: Date,
        grade: Domain.Entity.Course.Grade?
    ) async throws -> [Domain.Entity.Course]
}

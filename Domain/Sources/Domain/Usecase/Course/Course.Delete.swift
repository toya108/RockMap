import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Course {
    struct Delete: PassthroughUsecaseProtocol, DeleteCourseUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.Delete.R>
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.Delete()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(id: String, parentPath: String) async throws {
            try await self.repository.request(
                parameters: .init(id: id, parentPath: parentPath)
            )
        }
    }
}

public protocol DeleteCourseUsecaseProtocol {
    func delete(id: String, parentPath: String) async throws
}

import DataLayer
import Foundation

public extension Domain.Usecase.Course {
    struct Search: SearchCourseUsecaseProtocol, PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Course.Search.R>
        public typealias Mapper = Domain.Mapper.Course

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Course.Search()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func search(text: String) async throws -> [Domain.Entity.Course] {
            let documents = try await self.repository.request(
                parameters: .init(text: text)
            )

            return documents.map { mapper.map(from: $0) }
        }
    }
}

public protocol SearchCourseUsecaseProtocol {
    func search(text: String) async throws -> [Domain.Entity.Course]
}

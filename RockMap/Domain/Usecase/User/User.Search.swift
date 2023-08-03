import DataLayer
import Foundation

public extension Domain.Usecase.User {
    struct Search: SearchUserUsecaseProtocol, PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.User.Search.R>
        public typealias Mapper = Domain.Mapper.User

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.User.Search()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func search(text: String) async throws -> [Domain.Entity.User] {
            let documents = try await self.repository.request(
                parameters: .init(text: text)
            )

            return documents.map { mapper.map(from: $0) }
        }
    }
}

public protocol SearchUserUsecaseProtocol {
    func search(text: String) async throws -> [Domain.Entity.User]
}

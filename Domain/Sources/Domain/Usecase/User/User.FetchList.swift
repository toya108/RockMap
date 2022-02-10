import DataLayer
import Foundation

public extension Domain.Usecase.User {
    struct FetchList: FetchUserListUsecaseProtocol, PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.User.FetchList.R>
        public typealias Mapper = Domain.Mapper.User

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.User.FetchList()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(startAt: Date) async throws -> [Domain.Entity.User] {
            let documents = try await self.repository.request(
                parameters: .init(startAt: startAt)
            )

            return documents.map { mapper.map(from: $0) }
        }
    }
}

public protocol FetchUserListUsecaseProtocol {
    func fetch(startAt: Date) async throws -> [Domain.Entity.User]
}

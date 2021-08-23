import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.User {
    struct Delete: UsecaseProtocol {
        public typealias Repository = Repositories.User.Delete
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(id: String) -> AnyPublisher<Void, Error> {
            repository.request(
                parameters: .init(id: id)
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }

    }
}

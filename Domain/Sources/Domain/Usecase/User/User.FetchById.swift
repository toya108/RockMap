
import Combine
import DataLayer

public extension Domain.Usecase.User {
    struct FetchById: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.User.FetchById
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetchUser(by id: String) -> AnyPublisher<Domain.Entity.User, Error> {
            repository.request(parameters: .init(id: id))
                .map { mapper.map(from: $0) }
                .eraseToAnyPublisher()
        }

    }
}


import Combine
import DataLayer

public extension Domain.Usecase.User {
    struct Update: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.User.Update
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(user: Domain.Entity.User) -> AnyPublisher<Void, Error> {
            self.repository.request(parameters: .init(user: self.mapper.reverse(to: user)))
                .map { _ in () }
                .eraseToAnyPublisher()
        }
    }
}

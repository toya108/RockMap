
import Combine
import DataLayer

public extension Domain.Usecase {
    struct User: UsecaseProtocol {
        public typealias Repository = Repositories.User.Get
        public typealias Mapper = Domain.Mapper.User

        var repository: Repositories.User.Get
        var mapper: Domain.Mapper.User

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetchUser(by id: String) -> AnyPublisher<Domain.Entity.User, Error> {
            self.toPublisher { promise in
                repository.request(parameters: .init(id: id)) { result in
                    switch result {
                        case let .success(response):
                            let entity = mapper.map(from: response)
                            promise(.success(entity))

                        case let .failure(error):
                            promise(.failure(error))
                    }
                }
            }
        }

    }
}


import Combine
import DataLayer

public extension Domain.Usecase.User {
    struct FetchById: UsecaseProtocol {
        public typealias Repository = Repositories.User.FetchById
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

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

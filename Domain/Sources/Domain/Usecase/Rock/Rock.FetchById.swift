
import Combine
import DataLayer

public extension Domain.Usecase.Rock {
    struct FetchById: UsecaseProtocol {
        public typealias Repository = Repositories.Rock.FetchById
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by id: String) -> AnyPublisher<Domain.Entity.Rock, Error> {
            repository.request(parameters: .init(id: id))
                .map {
                    mapper.map(from: $0)
                }
                .eraseToAnyPublisher()
        }

    }
}

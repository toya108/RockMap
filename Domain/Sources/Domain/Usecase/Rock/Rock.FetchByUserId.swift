
import Combine
import DataLayer

public extension Domain.Usecase.Rock {
    struct FetchByUserId: UsecaseProtocol {
        public typealias Repository = Repositories.Rock.FetchByUserId
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by userId: String) -> AnyPublisher<[Domain.Entity.Rock], Error> {
            repository.request(
                parameters: .init(userId: userId)
            )
            .map { responses -> [Domain.Entity.Rock] in
                responses.map { mapper.map(from: $0) }
            }
            .eraseToAnyPublisher()
        }

    }
}

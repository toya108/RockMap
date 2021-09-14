import Combine
import DataLayer

public extension Domain.Usecase.Rock {
    struct FetchAll: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Rock.FetchAll
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetchAll() -> AnyPublisher<[Domain.Entity.Rock], Error> {
            self.repository.request(parameters: .init())
                .map { responses -> [Domain.Entity.Rock] in
                    responses.map { mapper.map(from: $0) }
                }
                .eraseToAnyPublisher()
        }
    }
}

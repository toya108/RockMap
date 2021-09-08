
import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchByRockId: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Course.FetchByRockId
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by rockId: String) -> AnyPublisher<[Domain.Entity.Course], Error> {
            repository.request(
                parameters: .init(rockId: rockId)
            )
            .map { responses -> [Domain.Entity.Course] in
                responses.map { mapper.map(from: $0) }
            }
            .eraseToAnyPublisher()
        }

    }
}

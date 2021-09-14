import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchByUserId: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Course.FetchByUserId
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by userId: String) -> AnyPublisher<[Domain.Entity.Course], Error> {
            self.repository.request(
                parameters: .init(userId: userId)
            )
            .map { responses -> [Domain.Entity.Course] in
                responses.map { mapper.map(from: $0) }
            }
            .eraseToAnyPublisher()
        }
    }
}

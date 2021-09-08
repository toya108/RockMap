import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct Set: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Course.Set
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(course: Domain.Entity.Course) -> AnyPublisher<Void, Error> {
            let document = mapper.reverse(to: course)
            return repository.request(
                parameters: .init(course: document)
            )
            .map { _ in ()}
            .eraseToAnyPublisher()
        }

    }
}

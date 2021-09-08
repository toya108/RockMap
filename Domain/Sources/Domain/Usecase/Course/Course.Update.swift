import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct Update: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Course.Set
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(from course: Domain.Entity.Course) -> AnyPublisher<Void, Error> {
            let document = self.mapper.reverse(to: course)
            return self.repository.request(parameters: .init(course: document))
                .map { _ in () }
                .eraseToAnyPublisher()
        }
    }
}

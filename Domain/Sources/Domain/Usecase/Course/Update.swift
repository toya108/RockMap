import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct Update: UsecaseProtocol {
        public typealias Repository = Repositories.Course.Set
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(course: Domain.Entity.Course) -> AnyPublisher<Void, Error> {
            self.toPublisher { promise in

                let document = mapper.reverse(to: course)

                repository.request(parameters: .init(course: document)) { result in
                    switch result {
                        case .success:
                            promise(.success(()))

                        case let .failure(error):
                            promise(.failure(error))
                    }
                }
            }
        }

    }
}


import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchByReference: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Course.FetchByReference
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by reference: String) -> AnyPublisher<Domain.Entity.Course, Error> {
            self.repository.request(parameters: .init(reference: reference))
                .map { mapper.map(from: $0) }
                .eraseToAnyPublisher()
        }
    }
}

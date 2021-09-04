import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct Delete: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Rock.Delete
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(id: String, parentPath: String) -> AnyPublisher<Void, Error> {
            repository.request(
                parameters: .init(id: id, parentPath: parentPath)
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }

    }
}

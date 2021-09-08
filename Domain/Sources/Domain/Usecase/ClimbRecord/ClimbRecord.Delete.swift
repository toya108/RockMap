import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.ClimbRecord {
    struct Delete: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.ClimbRecord.Delete
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func delete(parentPath: String, id: String) -> AnyPublisher<Void, Error> {
            repository.request(
                parameters: .init(parentPath: parentPath, id: id)
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }

    }
}

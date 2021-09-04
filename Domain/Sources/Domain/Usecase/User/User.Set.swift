
import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.User {
    struct Set: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.User.Set
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(
            id: String,
            createdAt: Date,
            displayName: String?,
            photoURL: URL?
        ) -> AnyPublisher<Void, Error> {
            return repository.request(
                parameters: .init(
                    id: id,
                    createdAt: createdAt,
                    displayName: displayName,
                    photoURL: photoURL
                )
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }

    }
}

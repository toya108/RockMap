import Combine
import DataLayer
import Foundation
import Resolver

public protocol SetUserUsecaseProtocol {

    func set(
        id: String,
        createdAt: Date,
        displayName: String?,
        photoURL: URL?
    ) -> AnyPublisher<Void, Error>

}

public extension Domain.Usecase.User {

    struct Set: SetUserUsecaseProtocol {

        @Injected var repository: Repositories.User.Set
        @Injected var mapper: Domain.Mapper.User

        public func set(
            id: String,
            createdAt: Date,
            displayName: String?,
            photoURL: URL?
        ) -> AnyPublisher<Void, Error> {
            self.repository.request(
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

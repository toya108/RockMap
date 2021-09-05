
import Combine
import DataLayer
import Foundation

public protocol DeleteImageUsecaseProtocol: UsecaseProtocol {
    func delete(path: String) -> AnyPublisher<Void, Error>
    init()
}

public extension Domain.Usecase.Image {
    struct Delete {}
}

public extension Domain.Usecase.Image.Delete {

    struct Header: DeleteImageUsecaseProtocol {
        let repository = Repositories.Storage.Header.Delete()

        public init() {}

        public func delete(path: String) -> AnyPublisher<Void, Error> {
            repository.request(
                parameters: .init(path: path)
            )
            .map { _ in ()}
            .eraseToAnyPublisher()
        }
    }

}

public extension Domain.Usecase.Image.Delete {

    struct Icon: DeleteImageUsecaseProtocol {
        let repository = Repositories.Storage.Icon.Delete()

        public init() {}

        public func delete(path: String) -> AnyPublisher<Void, Error> {
            repository.request(
                parameters: .init(path: path)
            )
            .map { _ in ()}
            .eraseToAnyPublisher()
        }
    }

}

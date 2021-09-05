
import Combine
import DataLayer
import Foundation

public protocol SetImageUsecaseProtocol: UsecaseProtocol {
    func set(path: String, data: Data) -> AnyPublisher<Void, Error>
    init()
}

public extension Domain.Usecase.Image {
    struct Set {}
}

public extension Domain.Usecase.Image.Set {

    struct Header: SetImageUsecaseProtocol {
        let repository = Repositories.Storage.Header.Set()

        public init() {}

        public func set(path: String, data: Data) -> AnyPublisher<Void, Error> {
            repository.request(
                parameters: .init(path: path, data: data)
            )
            .map { _ in ()}
            .eraseToAnyPublisher()
        }
    }

}

public extension Domain.Usecase.Image.Set {

    struct Icon: SetImageUsecaseProtocol {
        let repository = Repositories.Storage.Icon.Set()

        public init() {}

        public func set(path: String, data: Data) -> AnyPublisher<Void, Error> {
            repository.request(
                parameters: .init(path: path, data: data)
            )
            .map { _ in ()}
            .eraseToAnyPublisher()
        }
    }

}

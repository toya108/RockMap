
import Combine
import DataLayer
import Foundation

public protocol SetImageUsecaseProtocol: UsecaseProtocol {
    func set(path: String, data: Data) -> AnyPublisher<Void, Error>
    init()
}

public extension Domain.Usecase.Image {
    struct Set: SetImageUsecaseProtocol {
        let repository = Repositories.Storage.Set()

        public init() {}

        public func set(path: String, data: Data) -> AnyPublisher<Void, Error> {
            self.repository.request(
                parameters: .init(path: path, data: data)
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }
    }
}
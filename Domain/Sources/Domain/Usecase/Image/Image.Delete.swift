
import Combine
import DataLayer
import Foundation

public protocol DeleteImageUsecaseProtocol: UsecaseProtocol {
    func delete(path: String) -> AnyPublisher<Void, Error>
    init()
}

public extension Domain.Usecase.Image {
    struct Delete: DeleteImageUsecaseProtocol {
        let repository = Repositories.Storage.Delete()

        public init() {}

        public func delete(path: String) -> AnyPublisher<Void, Error> {
            self.repository.request(
                parameters: .init(path: path)
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }
    }
}


import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct Set: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.Rock.Set
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(rock: Domain.Entity.Rock) -> AnyPublisher<Void, Error> {
            let document = self.mapper.reverse(to: rock)
            return self.repository.request(
                parameters: .init(rock: document)
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }
    }
}


import Foundation
import Combine
import DataLayer

public extension Domain.Usecase.Rock {
    struct Update: UsecaseProtocol {
        public typealias Repository = Repositories.Rock.Update
        public typealias Mapper = Domain.Mapper.Rock

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(rock: Domain.Entity.Rock) -> AnyPublisher<Void, Error> {
            let document = mapper.reverse(to: rock)
            return repository.request(
                parameters: .init(rock: document)
            )
            .map { _ in ()}
            .eraseToAnyPublisher()
        }

    }
}


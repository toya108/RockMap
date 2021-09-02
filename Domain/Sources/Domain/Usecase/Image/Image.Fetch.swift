
import Combine
import DataLayer

public extension Domain.Usecase.Image {
    struct Fetch: UsecaseProtocol {
        public typealias Repository = Repositories.Storage.Header.Fetch
        public typealias Mapper = Domain.Mapper.Image

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetchHeader(
            id: String,
            destination: ImageDestination
        ) -> AnyPublisher<Domain.Entity.Image, Error> {
            repository.request(
                parameters: .init(
                    documentId: id,
                    collectionType: destination.to
                )
            )
            .map { mapper.map(from: $0) }
            .eraseToAnyPublisher()
        }

    }
}

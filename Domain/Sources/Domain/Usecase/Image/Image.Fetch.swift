
import Combine
import DataLayer

public extension Domain.Usecase.Image {
    struct Fetch<R: RepositoryProtocol>: PassthroughUsecaseProtocol where R.Request: StorageRequestProtocol {
        public typealias Repository = R
        public typealias Mapper = Domain.Mapper.Image

        var repository: R
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }
    }
}

public extension Domain.Usecase.Image.Fetch where R == Repositories.Storage.Header.Fetch {

    func fetch(
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

public extension Domain.Usecase.Image.Fetch where R == Repositories.Storage.Icon.Fetch {

    func fetch(
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

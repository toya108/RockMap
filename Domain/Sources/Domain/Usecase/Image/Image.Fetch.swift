import Combine
import DataLayer

protocol FetchImageUsecaseProtocol: PassthroughUsecaseProtocol {
    associatedtype Response
    func fetch(id: String, destination: ImageDestination) -> AnyPublisher<Response, Error>
}

public extension Domain.Usecase.Image {
    struct Fetch {}
}

public extension Domain.Usecase.Image.Fetch {
    struct Header: FetchImageUsecaseProtocol {
        public typealias Repository = Repositories.Storage.Fetch.Header
        public typealias Mapper = Domain.Mapper.Image

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(
            id: String,
            destination: ImageDestination
        ) -> AnyPublisher<Domain.Entity.Image, Error> {
            self.repository.request(
                parameters: .init(
                    documentId: id,
                    collectionType: destination.to,
                    directory: .header
                )
            )
            .map { mapper.map(from: $0) }
            .eraseToAnyPublisher()
        }
    }

    struct Icon: FetchImageUsecaseProtocol {
        public typealias Repository = Repositories.Storage.Fetch.Icon
        public typealias Mapper = Domain.Mapper.Image

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(
            id: String,
            destination: ImageDestination
        ) -> AnyPublisher<Domain.Entity.Image, Error> {
            self.repository.request(
                parameters: .init(
                    documentId: id,
                    collectionType: destination.to,
                    directory: .icon
                )
            )
            .map { mapper.map(from: $0) }
            .eraseToAnyPublisher()
        }
    }

    struct Normal: FetchImageUsecaseProtocol {
        public typealias Repository = Repositories.Storage.Fetch.Normal
        public typealias Mapper = Domain.Mapper.Image

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(
            id: String,
            destination: ImageDestination
        ) -> AnyPublisher<[Domain.Entity.Image], Error> {
            self.repository.request(
                parameters: .init(
                    documentId: id,
                    collectionType: destination.to,
                    directory: .normal
                )
            )
            .map { images in
                images.map {
                    mapper.map(from: $0)
                }
            }
            .eraseToAnyPublisher()
        }
    }
}

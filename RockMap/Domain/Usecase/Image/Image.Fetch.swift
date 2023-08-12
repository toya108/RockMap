import Combine
import DataLayer

protocol FetchImageUsecaseProtocol: PassthroughUsecaseProtocol {
    associatedtype Response
    func fetch(id: String, destination: ImageDestination) async throws -> Response
}

public extension Domain.Usecase.Image {
    struct Fetch {}
}

public extension Domain.Usecase.Image.Fetch {
    struct Header: FetchImageUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Storage.Fetch.Header.R>
        public typealias Mapper = Domain.Mapper.Image

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Storage.Fetch.Header()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(
            id: String,
            destination: ImageDestination
        ) async throws -> Domain.Entity.Image {
            let image = try await self.repository.request(
                parameters: .init(
                    documentId: id,
                    collectionType: destination.to,
                    directory: .header
                )
            )
            return mapper.map(from: image)
        }
    }

    struct Icon: FetchImageUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Storage.Fetch.Icon.R>
        public typealias Mapper = Domain.Mapper.Image

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Storage.Fetch.Icon()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(
            id: String,
            destination: ImageDestination
        ) async throws -> Domain.Entity.Image {
            let image = try await self.repository.request(
                parameters: .init(
                    documentId: id,
                    collectionType: destination.to,
                    directory: .icon
                )
            )
            return mapper.map(from: image)
        }
    }

    struct Normal: FetchImageUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.Storage.Fetch.Normal.R>
        public typealias Mapper = Domain.Mapper.Image

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.Storage.Fetch.Normal()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(
            id: String,
            destination: ImageDestination
        ) async throws -> [Domain.Entity.Image] {
            let images = try await self.repository.request(
                parameters: .init(
                    documentId: id,
                    collectionType: destination.to,
                    directory: .normal
                )
            )
            return images.map { mapper.map(from: $0) }
        }
    }
}

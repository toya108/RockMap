import Combine
import Foundation

public protocol WriteImageUsecaseProtocol: UsecaseProtocol {
    associatedtype Set: SetImageUsecaseProtocol
    associatedtype Delete: DeleteImageUsecaseProtocol

    var setUsecase: Set { get }
    var deleteUsecase: Delete { get }

    func write(
        data: Data?,
        shouldDelete: Bool,
        image: Domain.Entity.Image,
        @StoragePathBuilder _ builder: () -> String
    ) async throws

    init(set: Set, delete: Delete)
}

public extension Domain.Usecase.Image {
    struct Write: WriteImageUsecaseProtocol {
        public typealias Set = Domain.Usecase.Image.Set
        public typealias Delete = Domain.Usecase.Image.Delete

        public var setUsecase: Domain.Usecase.Image.Set
        public var deleteUsecase: Domain.Usecase.Image.Delete

        public init(set: Set = .init(), delete: Delete = .init()) {
            self.setUsecase = set
            self.deleteUsecase = delete
        }

        public func write(
            data: Data?,
            shouldDelete: Bool,
            image: Domain.Entity.Image,
            @StoragePathBuilder _ builder: () -> String
        ) async throws {
            if shouldDelete, let path = image.fullPath {
                try await self.deleteUsecase.delete(path: path)
                return
            }

            if let path = image.fullPath, let data = data {
                try await self.setUsecase.set(path: path, data: data)
                return
            }

            if let data = data {
                try await self.setUsecase.set(path: builder(), data: data)
                return
            }
        }
    }
}


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
    ) -> AnyPublisher<Void, Error>

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
        ) -> AnyPublisher<Void, Error> {
            if shouldDelete, let path = image.fullPath {
                return self.deleteUsecase.delete(path: path)
            }

            if let path = image.fullPath, let data = data {
                return self.setUsecase.set(path: path, data: data)
            }

            if let data = data {
                return self.setUsecase.set(path: builder(), data: data)
            }

            return Deferred {
                Future<Void, Error> { promise in
                    promise(.success(()))
                }
            }.eraseToAnyPublisher()
        }
    }
}

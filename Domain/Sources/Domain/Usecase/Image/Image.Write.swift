
import Combine
import Foundation

public extension Domain.Usecase.Image {

    struct Write<S: SetImageUsecaseProtocol, D: DeleteImageUsecaseProtocol>: UsecaseProtocol {

        let setUsecase = S()
        let deleteUsecase = D()

        public init() {}

        public func write(
            data: Data?,
            shouldDelete: Bool,
            image: Domain.Entity.Image,
            @StoragePathBuilder _ builder: () -> String
        ) -> AnyPublisher<Void, Error> {
            if shouldDelete, let path = image.fullPath {
                return deleteUsecase.delete(path: path)
            }

            if let path = image.fullPath, let data = data {
                return setUsecase.set(path: path, data: data)
            }

            if let data = data {
                return setUsecase.set(path: builder(), data: data)
            }

            return Deferred {
                Future<Void, Error> { promise in
                    promise(.success(()))
                }
            }.eraseToAnyPublisher()
        }

//        public func write(
//            data: Data?,
//            shouldDelete: Bool,
//            @PathBuilder _ builder: () -> String
//        ) -> AnyPublisher<Void, Error> {
//            if shouldDelete {
//                return deleteUsecase.delete(path: path)
//            }
//
//            if let data = data {
//                return setUsecase.set(path: builder(), data: data)
//            }
//
//            return .init(Empty())
//        }




    }

}

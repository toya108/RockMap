
import Foundation

public protocol RepositoryProtocol {
    associatedtype Request: RequestProtocol

    func request(
        useTestData: Bool,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    )

    func request(parameters: Request.Parameters) -> Request.Response?
}

public struct Repository<Request: RequestProtocol>: RepositoryProtocol {
    public init() {}

    public func request(
        useTestData: Bool = false,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) {
        assertionFailure("don't use default request")
    }

    @discardableResult
    public func request(parameters: Request.Parameters) -> Request.Response? {
        let item = Request(parameters: parameters)
        return item.localDataInterceptor(parameters)
    }
}

public extension Repository where Request: FirestoreRequestProtocol, Request.Entry == FSQuery {

    func request(
        useTestData: Bool = false,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) {
        let item = Request(parameters: parameters)
        FireStoreClient().request(
            item: item,
            useTestData: useTestData,
            completion: completion
        )
    }

}

public extension Repository where Request: FSListenable {

    func listen(
        useTestData: Bool = false,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) -> FSListenerRegistration? {
        let item = Request(parameters: parameters)
        return FireStoreClient().listen(
            item: item,
            useTestData: useTestData,
            completion: completion
        )
    }

}

public extension Repository where Request: FirestoreRequestProtocol, Request.Entry == FSDocument {

    func request(
        useTestData: Bool = false,
        parameters: Request.Parameters,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) {
        let item = Request(parameters: parameters)
        FireStoreClient().request(
            item: item,
            useTestData: useTestData,
            completion: completion
        )
    }
}

import Foundation

public protocol RepositoryProtocol {
    associatedtype R: RequestProtocol
    func request(parameters: R.Parameters) async throws -> R.Response
}

public struct AnyRepository<Request: RequestProtocol>: RepositoryProtocol {
    public typealias R = Request

    private let _reguest: (Request.Parameters) async throws -> Request.Response

    public init<F: RepositoryProtocol>(_ base: F) where F.R == Request {
        self._reguest = { try await base.request(parameters: $0)  }
    }

    @discardableResult
    public func request(parameters: Request.Parameters) async throws -> Request.Response {
        try await _reguest(parameters)
    }
}

public extension RepositoryProtocol where R: FirestoreRequestProtocol {

    func request(parameters: R.Parameters) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

public extension RepositoryProtocol where R: FirestoreRequestProtocol, R.Parameters == EmptyParameters {

    func request(parameters: R.Parameters = .init()) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

public extension RepositoryProtocol where R: FirestoreRequestProtocol, R.Response == EmptyResponse {

    func request(parameters: R.Parameters) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

public extension RepositoryProtocol where R: StorageRequestProtocol {

    func request(parameters: R.Parameters) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

public extension RepositoryProtocol where R: StorageRequestProtocol, R.Parameters == EmptyParameters {

    func request(parameters: R.Parameters = .init()) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

public extension RepositoryProtocol where R: StorageRequestProtocol, R.Response == EmptyResponse {

    func request(parameters: R.Parameters) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

public extension RepositoryProtocol where R: LocalRequest {

    @discardableResult
    func request(parameters: R.Parameters) -> R.Response {
        R().intercept(parameters)
    }

}

public extension RepositoryProtocol where R: LocalRequest, R.Parameters == EmptyParameters {

    @discardableResult
    func request(parameters: R.Parameters = .init()) -> R.Response {
        R().intercept(parameters)
    }

}

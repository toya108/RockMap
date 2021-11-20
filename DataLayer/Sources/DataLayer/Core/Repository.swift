import Foundation

protocol RepositoryProtocol {
    associatedtype R: RequestProtocol
    func request(parameters: R.Parameters) async throws -> R.Response
}

struct AnyRepository<Request: RequestProtocol>: RepositoryProtocol {
    typealias R = Request

    private let _reguest: (Request.Parameters) async throws -> Request.Response

    init<F: RepositoryProtocol>(_ base: F) where F.R == Request {
        self._reguest = { try await base.request(parameters: $0)  }
    }

    func request(parameters: Request.Parameters) async throws -> Request.Response {
        try await _reguest(parameters)
    }
}

extension RepositoryProtocol where R: FirestoreRequestProtocol {

    func request(parameters: R.Parameters) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

extension RepositoryProtocol where R: FirestoreRequestProtocol, R.Parameters == EmptyParameters {

    func request(parameters: R.Parameters = .init()) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

extension RepositoryProtocol where R: StorageRequestProtocol {

    func request(parameters: R.Parameters) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

extension RepositoryProtocol where R: StorageRequestProtocol, R.Parameters == EmptyParameters {

    func request(parameters: R.Parameters = .init()) async throws -> R.Response {
        try await R(parameters: parameters).request()
    }

}

extension RepositoryProtocol where R: LocalRequest {

    @discardableResult
    func request(parameters: R.Parameters) -> R.Response {
        R().intercept(parameters)
    }

}

extension RepositoryProtocol where R: LocalRequest, R.Parameters == EmptyParameters {

    @discardableResult
    func request(parameters: R.Parameters = .init()) -> R.Response {
        R().intercept(parameters)
    }

}

public protocol StorageRequestProtocol: RequestProtocol {
    @PathBuilder
    var path: String { get }

    var parameters: Parameters { get set }
    init(parameters: Parameters)

    func request() async throws -> Response
}

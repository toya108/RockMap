public protocol StorageRequestProtocol: RequestProtocol {
    @PathBuilder
    var path: String { get }
}

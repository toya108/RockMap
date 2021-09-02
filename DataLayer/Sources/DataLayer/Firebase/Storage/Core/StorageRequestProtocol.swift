
public protocol StorageRequestProtocol: RequestProtocol {

    associatedtype Directory: ImageDirectoryProtocol

    @PathBuilder
    var path: String { get }
}

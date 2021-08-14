
public protocol StorageRequestProtocol: RequestProtocol {
    associatedtype Collection: CollectionProtocol

    var method: StorageMethod { get }

    @PathBuilder
    var path: String { get }

}

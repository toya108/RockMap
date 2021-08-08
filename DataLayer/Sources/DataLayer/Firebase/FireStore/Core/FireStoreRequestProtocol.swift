
public protocol FirestoreRequestProtocol: RequestProtocol {
    associatedtype Collection: CollectionProtocol
    var method: FirestoreMethod { get }
    @PathBuilder
    var path: String { get }
}


public protocol FirestoreRequestProtocol: RequestProtocol {
    associatedtype Collection: CollectionProtocol
    associatedtype Entry: FireStoreEntryprotocol

    var method: FirestoreMethod { get }

    @PathBuilder
    var path: String { get }

    var entry: Entry { get }
}

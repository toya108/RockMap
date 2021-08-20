
public protocol FirestoreRequestProtocol: RequestProtocol {
    associatedtype Collection: CollectionProtocol
    associatedtype Entry: FireStoreEntryprotocol

    @PathBuilder
    var path: String { get }

    var entry: Entry { get }
}

extension FirestoreRequestProtocol {
    static var Document: DocumentProtocol.Type { Collection.Document }
}

extension FirestoreRequestProtocol where Entry == FSQuery {
    public var path: String { "" }
}

public protocol FSListenable: FirestoreRequestProtocol where Entry == FSQuery {}

import Combine

public protocol FirestoreRequestBaseProcotol: RequestProtocol {
    associatedtype Collection: CollectionProtocol
    associatedtype Entry: FireStoreEntryprotocol

    @PathBuilder
    var path: String { get }
    var entry: Entry { get }

    var parameters: Parameters { get }
    init(parameters: Parameters)
}

extension FirestoreRequestBaseProcotol {
    static var Document: DocumentProtocol.Type { Collection.Document }
}

public extension FirestoreRequestBaseProcotol where Entry == FSQuery {
    var path: String { "" }
}

public protocol FirestoreRequestProtocol: FirestoreRequestBaseProcotol {
    func request() async throws -> Response
}

public protocol FirestoreListenableProtocol: FirestoreRequestBaseProcotol where Entry == FSQuery {
    func request() -> AnyPublisher<Response, Error>
}

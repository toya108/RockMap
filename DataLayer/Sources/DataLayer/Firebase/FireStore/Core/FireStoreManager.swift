
import FirebaseFirestore
import Utilities

typealias FSValue = FieldValue
public typealias FSQuery = Query

struct FirestoreManager {
    static let db = Firestore.firestore()
    static let encoder = Firestore.Encoder()
    static let decoder = Firestore.Decoder()
}

public enum FirestoreMethod {
    case set
    case get
    case delete
    case update
}

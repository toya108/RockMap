
import FirebaseFirestore
import Utilities

struct FirestoreManager {
    static let db = Firestore.firestore()
    static let encoder = Firestore.Encoder()
    static let decoder = Firestore.Decoder()

    typealias Value = FieldValue
}

public enum FirestoreMethod {
    case set
    case get
    case delete
    case update
}

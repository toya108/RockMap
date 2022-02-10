import FirebaseFirestore
import Utilities

typealias FSValue = FieldValue
public typealias FSQuery = Query
public typealias FSCollection = CollectionReference

struct FirestoreManager {
    static let db = Firestore.firestore()
    static let encoder = Firestore.Encoder()
    static let decoder = Firestore.Decoder()
}

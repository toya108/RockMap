
import Foundation

public protocol CollectionProtocol {
    static var Document: DocumentProtocol.Type { get }
    static var name: String { get }
    static var isRoot: Bool { get }
}

public extension CollectionProtocol {
    static var isRoot: Bool { false }
    static var group: FSQuery {
        FirestoreManager.db.collectionGroup(Self.name)
    }
}

public extension FS.Collection {
    struct Users: CollectionProtocol {
        public static var Document: DocumentProtocol.Type {
            FS.Document.User.self
        }

        public static var name: String { "users" }
        public static var isRoot: Bool { true }
    }

    struct Rocks: CollectionProtocol {
        public static var Document: DocumentProtocol.Type {
            FS.Document.Rock.self
        }

        public static var name: String { "rocks" }
    }

    struct Courses: CollectionProtocol {
        public static var Document: DocumentProtocol.Type {
            FS.Document.Course.self
        }

        public static var name: String { "courses" }
    }

    struct ClimbRecord: CollectionProtocol {
        public static var Document: DocumentProtocol.Type {
            FS.Document.ClimbRecord.self
        }

        public static var name: String { "climbRecord" }
    }

    struct TotalClimbedNumber: CollectionProtocol {
        public static var Document: DocumentProtocol.Type {
            FS.Document.TotalClimbedNumber.self
        }

        public static var name: String { "totalClimbedNumber" }
    }
}

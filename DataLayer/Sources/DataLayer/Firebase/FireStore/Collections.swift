
import Foundation

public protocol CollectionProtocol {
    static var name: String { get }
    static var isRoot: Bool { get }
}

public extension CollectionProtocol {
    static var isRoot: Bool { false }
}

public extension FS.Collection {
    struct Users: CollectionProtocol {
        public static var name: String { "users" }
        public static var isRoot: Bool { true }
    }

    struct Rocks: CollectionProtocol {
        public static var name: String { "users" }
    }

    struct Cources: CollectionProtocol {
        public static var name: String { "cources" }
    }

    struct ClimbRecord: CollectionProtocol {
        public static var name: String { "climbRecord" }
    }

    struct TotalClimbedNumber: CollectionProtocol {
        public static var name: String { "totalClimbedNumber" }
    }
}

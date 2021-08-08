
import Foundation

public protocol CollectionProtocol {
    static var name: String { get }
    static var isRoot: Bool { get }
}

public extension CollectionProtocol {
    static var isRoot: Bool { false }
}

extension FS.Collection {
    struct Users: CollectionProtocol {
        static var name: String { "users" }
        static var isRoot: Bool { true }
    }

    struct Rocks: CollectionProtocol {
        static var name: String { "users" }
    }

    struct Cources: CollectionProtocol {
        static var name: String { "cources" }
    }

    struct ClimbRecord: CollectionProtocol {
        static var name: String { "climbRecord" }
    }

    struct TotalClimbedNumber: CollectionProtocol {
        static var name: String { "totalClimbedNumber" }
    }
}

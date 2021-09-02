
public protocol ImageDirectoryProtocol {
    static var name: String { get }
}

public extension FireStorage.ImageDirectory {

    struct Header: ImageDirectoryProtocol {
        public static var name: String { "header" }
    }

    struct Normal: ImageDirectoryProtocol {
        public static var name: String { "normal" }
    }

    struct Icon: ImageDirectoryProtocol {
        public static var name: String { "icon" }
    }

}

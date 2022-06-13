import Foundation

public extension NSObjectProtocol {
    static var className: String {
        String(describing: self)
    }
}

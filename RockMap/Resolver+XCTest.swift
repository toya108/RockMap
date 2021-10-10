import Foundation
import Resolver
@testable import RockMap
@testable import Auth

extension Resolver {

    static var mock = Resolver(parent: .main)

    public static func registerMockServices() {
        Resolver.root = mock
    }
}

import Resolver
@testable import RockMap

extension Resolver {

    static var mock = Resolver(parent: .main)

    public static func registerMockServices() {
        Resolver.root = mock
    }
}

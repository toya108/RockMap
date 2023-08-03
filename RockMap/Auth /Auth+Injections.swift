import Resolver

public extension Resolver {
    static func registerAuthServices() {
        register { AuthAccessor() as AuthAccessorProtocol }
        register { AuthCoordinator() as AuthCoordinatorProtocol }
    }
}

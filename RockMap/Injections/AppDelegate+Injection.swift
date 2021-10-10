import Resolver
import Auth

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { AuthAccessor() as AuthAccessorProtocol }
        register { AuthCoordinator() as AuthCoordinatorProtocol }
        register { LoginViewModel() }
    }
}

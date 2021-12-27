import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerRockMapServices()
        registerAuthServices()
        registerDomainServices()
    }

    static private func registerRockMapServices() {
        register { LoginViewModel() }
        register { AccountViewModel() }
    }
}

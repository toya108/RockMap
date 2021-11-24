import Resolver

public extension Resolver {

    static func registerDataServices() {
        register { AnyRepository(Repositories.User.Set()) }
    }
    
}

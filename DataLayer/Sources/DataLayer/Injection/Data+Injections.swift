import Resolver

public extension Resolver {

    static func registerDataServices() {
        register { Repositories.User.Set() }
    }
    
}

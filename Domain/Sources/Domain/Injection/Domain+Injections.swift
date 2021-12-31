import DataLayer
import Resolver

public extension Resolver {
    static func registerDomainServices() {
        registerDataServices()
        _registerDomainServices()
    }

    private static func _registerDomainServices() {
        register { Domain.Usecase.User.Set() as SetUserUsecaseProtocol }
        register { Domain.Mapper.User() }
        register { Domain.Usecase.User.Delete() as DeleteUserUsecaseProtocol }
    }
}


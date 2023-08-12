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
        register { Domain.Usecase.User.FetchList() as FetchUserListUsecaseProtocol }
        register { Domain.Usecase.User.Search() as SearchUserUsecaseProtocol }
        register { Domain.Usecase.Rock.FetchByUserId() as FetchRockUsecaseProtocol }
        register { Domain.Usecase.Rock.Search() as SearchRockUsecaseProtocol }
        register { Domain.Usecase.Rock.Delete() as DeleteRockUsecaseProtocol }
        register { Domain.Usecase.Rock.FetchList() as FetchRockListUsecaseProtocol }
        register { Domain.Usecase.Course.FetchByUserId() as FetchCourseUsecaseProtocol }
        register { Domain.Usecase.Course.Delete() as DeleteCourseUsecaseProtocol }
        register { Domain.Usecase.Course.FetchList() as FetchCourseListUsecaseProtocol }
        register { Domain.Usecase.Course.Search() as SearchCourseUsecaseProtocol }
    }
}



import DataLayer

public enum ImageDestination {
    case rock
    case course
    case user

    var to: CollectionProtocol.Type {
        switch self {
            case .rock:
                return FS.Collection.Rocks.self

            case .course:
                return FS.Collection.Courses.self

            case .user:
                return FS.Collection.Users.self
        }
    }

    var name: String {
        switch self {
            case .rock:
                return "rocks"

            case .course:
                return "courses"

            case .user:
                return "users"
        }
    }
}

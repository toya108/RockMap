public struct Repositories {
    public struct User {
        public struct FetchById: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.FetchById
            public init() {}
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.Update
            public init() {}
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.Delete
            public init() {}
        }
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.Set
            public init() {}
        }
    }

    public struct Rock {
        public struct FetchAll: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.FetchAll
            public init() {}
        }
        public struct FetchById: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.FetchById
            public init() {}
        }
        public struct FetchByUserId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.FetchByUserId
            public init() {}
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.Delete
            public init() {}
        }
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.Set
            public init() {}
        }
        public struct Search: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.Search
            public init() {}
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.Update
            public init() {}
        }
    }

    public struct Course {
        public struct FetchByUserId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.FetchByUserId
            public init() {}
        }
        public struct FetchByRockId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.FetchByRockId
            public init() {}
        }
        public struct FetchByReference: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.FetchByReference
            public init() {}
        }
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.Set
            public init() {}
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.Update
            public init() {}
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.Delete
            public init() {}
        }
    }

    public struct ClimbRecord {
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.Set
            public init() {}
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.Update
            public init() {}
        }
        public struct FetchByCourseId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.FetchByCourseId
            public init() {}
        }
        public struct FetchByUserId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.FetchByUserId
            public init() {}
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.Delete
            public init() {}
        }
    }

    public struct TotalClimbedNumber {
        public struct ListenByCourseId: ListenableRepositoryProtocol, Initializable {
            public typealias R = FS.Request.TotalClimbedNumber.ListenByCourseId
            public init() {}
        }
    }

    public struct Storage {
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FireStorage.Request.Set
            public init() {}
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FireStorage.Request.Delete
            public init() {}
        }
        public struct Fetch {
            public struct Header: RepositoryProtocol, Initializable {
                public typealias R = FireStorage.Request.Fetch.Header
                public init() {}
            }
            public struct Icon: RepositoryProtocol, Initializable {
                public typealias R = FireStorage.Request.Fetch.Icon
                public init() {}
            }
            public struct Normal: RepositoryProtocol, Initializable {
                public typealias R = FireStorage.Request.Fetch.Normal
                public init() {}
            }
        }
    }
}

public protocol Initializable {
    init()
}

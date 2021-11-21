public struct Repositories {
    public struct User {
        public struct FetchById: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.FetchById
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.Update
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.Delete
        }
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.User.Set
        }
    }

    public struct Rock {
        public struct FetchAll: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.FetchAll
        }
        public struct FetchById: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.FetchById
        }
        public struct FetchByUserId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.FetchByUserId
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.Delete
        }
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.Set
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Rock.Update
        }
    }

    public struct Course {
        public struct FetchByUserId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.FetchByUserId
        }
        public struct FetchByRockId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.FetchByRockId
        }
        public struct FetchByReference: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.FetchByReference
        }
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.Set
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.Update
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.Course.Delete
        }
    }

    public struct ClimbRecord {
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.Set
        }
        public struct Update: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.Update
        }
        public struct FetchByCourseId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.FetchByCourseId
        }
        public struct FetchByUserId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.FetchByUserId
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.ClimbRecord.Delete
        }
    }

    public struct TotalClimbedNumber {
        public struct ListenByCourseId: RepositoryProtocol, Initializable {
            public typealias R = FS.Request.TotalClimbedNumber.ListenByCourseId
        }
    }

    public struct Storage {
        public struct Set: RepositoryProtocol, Initializable {
            public typealias R = FireStorage.Request.Set
        }
        public struct Delete: RepositoryProtocol, Initializable {
            public typealias R = FireStorage.Request.Delete
        }
        public struct Fetch {
            public struct Header: RepositoryProtocol, Initializable {
                public typealias R = FireStorage.Request.Fetch.Header
            }
            public struct Icon: RepositoryProtocol, Initializable {
                public typealias R = FireStorage.Request.Fetch.Icon
            }
            public struct Normal: RepositoryProtocol, Initializable {
                public typealias R = FireStorage.Request.Fetch.Normal
            }
        }
    }
}

public protocol Initializable {}

extension Initializable {
    public init() {
        self.init()
    }
}

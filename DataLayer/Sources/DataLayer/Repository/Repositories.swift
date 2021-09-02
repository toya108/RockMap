
public struct Repositories {
    public struct User {
        public typealias FetchById = Repository<FS.Request.User.FetchById>
        public typealias Update = Repository<FS.Request.User.Update>
        public typealias Delete = Repository<FS.Request.User.Delete>
        public typealias Set = Repository<FS.Request.User.Set>
    }
    public struct Rock {
        public typealias FetchAll = Repository<FS.Request.Rock.FetchAll>
        public typealias FetchById = Repository<FS.Request.Rock.FetchById>
        public typealias FetchByUserId = Repository<FS.Request.Rock.FetchByUserId>
        public typealias Delete = Repository<FS.Request.Rock.Delete>
        public typealias Set = Repository<FS.Request.Rock.Set>
        public typealias Update = Repository<FS.Request.Rock.Update>
    }
    public struct Course {
        public typealias FetchByUserId = Repository<FS.Request.Course.FetchByUserId>
        public typealias FetchByRockId = Repository<FS.Request.Course.FetchByRockId>
        public typealias FetchByReference = Repository<FS.Request.Course.FetchByReference>
        public typealias Set = Repository<FS.Request.Course.Set>
        public typealias Update = Repository<FS.Request.Course.Update>
        public typealias Delete = Repository<FS.Request.Course.Delete>
    }
    public struct ClimbRecord {
        public typealias Set = Repository<FS.Request.ClimbRecord.Set>
        public typealias Update = Repository<FS.Request.ClimbRecord.Update>
        public typealias FetchByCourseId = Repository<FS.Request.ClimbRecord.FetchByCourseId>
        public typealias FetchByUserId = Repository<FS.Request.ClimbRecord.FetchByUserId>
        public typealias Delete = Repository<FS.Request.ClimbRecord.Delete>
    }
    public struct TotalClimbedNumber {
        public typealias ListenByCourseId = Repository<FS.Request.TotalClimbedNumber.ListenByCourseId>
    }

    public struct Storage {
        public struct Header {
            public typealias Fetch = Repository<FireStorage.Request.Header.Fetch>
            public typealias Delete = Repository<FireStorage.Request.Header.Delete>
            public typealias Set = Repository<FireStorage.Request.Header.Set>
        }
        public struct Icon {
            public typealias Fetch = Repository<FireStorage.Request.Icon.Fetch>
            public typealias Delete = Repository<FireStorage.Request.Icon.Delete>
            public typealias Set = Repository<FireStorage.Request.Icon.Set>
        }
    }
}

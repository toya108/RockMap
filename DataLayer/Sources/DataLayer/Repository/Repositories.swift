
public struct Repositories {
    public struct User {
        public typealias FetchById = Repository<FS.Request.User.FetchById>
    }
    public struct Course {
        public typealias FetchByUserId = Repository<FS.Request.Course.FetchByUserId>
        public typealias FetchByRockId = Repository<FS.Request.Course.FetchByRockId>
        public typealias Set = Repository<FS.Request.Course.Set>
        public typealias Update = Repository<FS.Request.Course.Update>
    }
    public struct TotalClimbedNumber {
        public typealias ListenByCourseId = Repository<FS.Request.TotalClimbedNumber.ListenByCourseId>
    }
}

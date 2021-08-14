
public struct Repositories {
    public struct User {
        public typealias FetchById = Repository<FS.Request.FetchById>
    }
    public struct Course {
        public typealias FetchByUserId = Repository<FS.Request.FetchByUserId>
        public typealias FetchByRockId = Repository<FS.Request.FetchByRockId>
        public typealias Set = Repository<FS.Request.Set>
        public typealias Update = Repository<FS.Request.Update>
    }
}

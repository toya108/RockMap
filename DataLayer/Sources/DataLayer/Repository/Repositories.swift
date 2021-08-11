
public struct Repositories {
    public struct User {
        public typealias Get = Repository<FS.Request.GetUser>
    }
    public struct Course {
        public typealias Get = Repository<FS.Request.GetCourses>
    }
}

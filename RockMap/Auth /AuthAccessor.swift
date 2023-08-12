import FirebaseAuth

public protocol AuthAccessorProtocol {
    var isLoggedIn: Bool { get }
    var uid: String { get }
    var providerID: String { get }
    var displayName: String { get }
    var userPath: String { get }
    func logout() throws
}

public struct AuthAccessor {

    private let auth: Auth

    public init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }

    private var currentUser: User? {
        auth.currentUser
    }

}

extension AuthAccessor: AuthAccessorProtocol {

    public var isLoggedIn: Bool {
        currentUser != nil
    }

    public var uid: String {
        currentUser?.uid ?? ""
    }

    public var providerID: String {
        self.currentUser?.providerID ?? ""
    }

    public var displayName: String {
        self.currentUser?.displayName ?? ""
    }

    public var userPath: String {
        "users" + "/" + self.uid
    }

    public func logout() throws {
        try self.auth.signOut()
    }
}

#if DEBUG

public struct MockLoggedInAuthAccessor: AuthAccessorProtocol {
    public var isLoggedIn: Bool = true
    public var uid: String = "123456789"
    public var providerID: String = "Firebase"
    public var displayName: String = "mogumogu"
    public var userPath: String = "users" + "/" + "123456789"
    public func logout() throws {}
}

public struct MockNoLoggedInAuthAccessor: AuthAccessorProtocol {

    enum LogoutError: LocalizedError {
        case failed
    }

    public var isLoggedIn: Bool = false
    public var uid: String = ""
    public var providerID: String = ""
    public var displayName: String = ""
    public var userPath: String = "users" + "/" + ""
    public func logout() throws {
        throw LogoutError.failed
    }
}

#endif

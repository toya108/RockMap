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

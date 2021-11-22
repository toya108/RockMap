import Combine
import FirebaseAuthUI
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import Utilities
import Resolver
import Domain

public class AuthManager: NSObject {
    public static let shared = AuthManager()

    private var setUserCancellable: AnyCancellable?
    private let loginFinishedSubject: PassthroughSubject<Result<Void, Error>, Never> = .init()
    @Injected private var setUserUsecase: SetUserUsecaseProtocol

    public let authUI: FUIAuth? = {
        guard
            let authUI = FUIAuth.defaultAuthUI()
        else {
            return nil
        }
        authUI.providers = [
            FUIGoogleAuth(authUI: authUI),
            FUIEmailAuth(),
            FUIOAuth.appleAuthProvider()
        ]
        return authUI
    }()

    override private init() {
        super.init()
        self.authUI?.delegate = self
    }

    public var loginFinishedPublisher: AnyPublisher<Result<Void, Error>, Never> {
        self.loginFinishedSubject.eraseToAnyPublisher()
    }

    public var isLoggedIn: Bool {
        self.currentUser != nil
    }

    public var uid: String {
        self.currentUser?.uid ?? ""
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

    public var authViewController: UIViewController? {
        self.authUI?.authViewController().viewControllers.first
    }

    public func logoutPublisher() -> AnyPublisher<Void, Error> {
        Deferred {
            Future<Void, Error> { [weak self] promise in
                do {
                    try self?.authUI?.signOut()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func logout() throws {
        try self.authUI?.signOut()
    }

    private var currentUser: User? {
        self.authUI?.auth?.currentUser
    }
}

extension AuthManager: FUIAuthDelegate {
    public func authUI(
        _ authUI: FUIAuth,
        didSignInWith authDataResult: AuthDataResult?,
        error: Error?
    ) {
        if let error = error {
            self.loginFinishedSubject.send(.failure(error))
            return
        }

        guard
            let user = authDataResult?.user
        else {
            self.loginFinishedSubject.send(.failure(AuthError.noUser))
            return
        }

        Task { [weak self] in

            guard let self = self else { return }

            do {
                let _ = try await self.setUserUsecase.set(
                    id: user.uid,
                    createdAt: user.metadata.creationDate ?? Date(),
                    displayName: user.displayName,
                    photoURL: user.photoURL
                )
                self.loginFinishedSubject.send(.success(()))
            } catch {
                self.loginFinishedSubject.send(.failure(error))
            }
        }
    }

}

public enum AuthError: LocalizedError {
    case noUser
}

private extension Publisher where Output == Void, Failure == Error {
    func handleLoginResult(
        _ loginFinishedSubject: PassthroughSubject<Result<Void, Error>, Never>
    ) -> AnyCancellable {
        self.catch { error -> Empty in
            if AuthManager.shared.isLoggedIn {
                AuthManager.shared.logout(completion: nil)
            }

            loginFinishedSubject.send(.failure(error))
            return Empty()
        }
        .sink { _ in
            loginFinishedSubject.send(.success(()))
        }
    }
}


import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI
import FirebaseOAuthUI
import Combine
import Utilities

class AuthManager: NSObject {

    static let shared = AuthManager()

    private var setUserCancellable: AnyCancellable?
    private let loginFinishedSubject: PassthroughSubject<Result<Void, Error>, Never> = .init()
    private let setUserUsecase = Usecase.User.Set()

    private let authUI: FUIAuth? = {
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

    private override init() {
        super.init()
        authUI?.delegate = self
    }

    var loginFinishedPublisher: AnyPublisher<Result<Void, Error>, Never> {
        loginFinishedSubject.eraseToAnyPublisher()
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    var currentUser: User? {
        authUI?.auth?.currentUser
    }

    var uid: String {
        currentUser?.uid ?? ""
    }

    var authViewController: UIViewController? {
        authUI?.authViewController().viewControllers.first
    }

    func logout() -> AnyPublisher<Void, Error> {
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

    func logout(_ completion: ((Result<Void, Error>) -> Void)?) {
        do {
            try self.authUI?.signOut()
            completion?(.success(()))
        } catch {
            completion?(.failure(error))
        }
    }
}

extension AuthManager: FUIAuthDelegate {

    func authUI(
        _ authUI: FUIAuth,
        didSignInWith authDataResult: AuthDataResult?,
        error: Error?
    ) {
        if let error = error {
            loginFinishedSubject.send(.failure(error))
            return
        }

        guard
            let user = authDataResult?.user
        else {
            loginFinishedSubject.send(.failure(AuthError.noUser))
            return
        }

        self.setUserCancellable = setUserUsecase.set(
            id: user.uid,
            createdAt: user.metadata.creationDate ?? Date(),
            displayName: user.displayName,
            photoURL: user.photoURL
        )
        .catch { [weak self] error -> Empty in

            guard let self = self else { return Empty() }

            self.loginFinishedSubject.send(.failure(error))
            return Empty()
        }
        .sink { [weak self] in
            guard let self = self else { return }

            self.loginFinishedSubject.send(.success(()))
        }

    }

    func authPickerViewController(
        forAuthUI authUI: FUIAuth
    ) -> FUIAuthPickerViewController {
        return FUICustomAuthPickerViewController(
            nibName: FUICustomAuthPickerViewController.className,
            bundle: Bundle.main,
            authUI: authUI
        )
    }

}

enum AuthError: LocalizedError {
    case noUser
}

private extension Publisher where Output == Void, Failure == Error {

    func handleLoginResult(
        _ loginFinishedSubject: PassthroughSubject<Result<Void, Error>, Never>
    ) -> AnyCancellable {
        self.catch { error -> Empty in
            if AuthManager.shared.isLoggedIn {
                AuthManager.shared.logout(nil)
            }

            loginFinishedSubject.send(.failure(error))
            return Empty()
        }
        .sink { _ in
            loginFinishedSubject.send(.success(()))
        }
    }

}
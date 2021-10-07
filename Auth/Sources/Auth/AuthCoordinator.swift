import Combine
import FirebaseAuthUI

public protocol AuthCoordinatorProtocol where Self: NSObject & FUIAuthDelegate {
    var loginFinishedPublisher: AnyPublisher<Result<Void, Error>, Never> { get }
}

public class AuthCoordinator: NSObject, AuthCoordinatorProtocol {

    private var setUserCancellable: Cancellable?
    private let setUserUsecase = Usecase.User.Set()
    private let loginFinishedSubject: PassthroughSubject<Result<Void, Error>, Never> = .init()

    public override init() {
        super.init()
    }

    public var loginFinishedPublisher: AnyPublisher<Result<Void, Error>, Never> {
        self.loginFinishedSubject.eraseToAnyPublisher()
    }
}

extension AuthCoordinator: FUIAuthDelegate {

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

        self.setUserCancellable = self.setUserUsecase.set(
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

    public func authPickerViewController(
        forAuthUI authUI: FUIAuth
    ) -> FUIAuthPickerViewController {
        FUICustomAuthPickerViewController(
            nibName: FUICustomAuthPickerViewController.className,
            bundle: Bundle.main,
            authUI: authUI
        )
    }
}

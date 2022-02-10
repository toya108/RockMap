import Combine
import FirebaseAuthUI
import Resolver
import Domain

public protocol AuthCoordinatorProtocol where Self: NSObject & FUIAuthDelegate {
    var loginFinishedPublisher: AnyPublisher<Result<Void, Error>, Never> { get }
}

public class AuthCoordinator: NSObject, AuthCoordinatorProtocol {

    private var setUserCancellable: Cancellable?
    private let loginFinishedSubject: PassthroughSubject<Result<Void, Error>, Never> = .init()
    @Injected private var setUserUsecase: SetUserUsecaseProtocol

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

        Task { [weak self] in

            guard let self = self else { return }

            do {
                let entity = Entity.User(
                    id: user.uid,
                    createdAt: user.metadata.creationDate ?? Date(),
                    name: user.displayName ?? "-",
                    photoURL: user.photoURL
                )
                try await self.setUserUsecase.set(user: entity)
                self.loginFinishedSubject.send(.success(()))
            } catch {
                self.loginFinishedSubject.send(.failure(error))
            }
        }
    }
}

#if DEBUG

public class MockAuthCoordinatorSucceded: NSObject, AuthCoordinatorProtocol, FUIAuthDelegate {
    public var loginFinishedPublisher: AnyPublisher<Result<Void, Error>, Never> {
        Future { promise in
            promise(.success(.success(())))
        }
        .eraseToAnyPublisher()
    }
}

public class MockAuthCoordinatorFailed: NSObject, AuthCoordinatorProtocol, FUIAuthDelegate {

    enum LoginError: LocalizedError {
        case failed
    }

    public var loginFinishedPublisher: AnyPublisher<Result<Void, Error>, Never> {
        Future { promise in
            promise(.success(.failure(LoginError.failed)))
        }
        .eraseToAnyPublisher()
    }
}

#endif

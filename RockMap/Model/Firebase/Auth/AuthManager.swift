//
//  AuthManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/03.
//

import FirebaseUI
import Firebase
import Combine

class AuthManager: NSObject {

    static let shared = AuthManager()

    private var bindings = Set<AnyCancellable>()
    private let loginFinishedSubject: PassthroughSubject<Result<Void, Error>, Never> = .init()

    private let authUI: FUIAuth? = {
        guard
            let authUI = FUIAuth.defaultAuthUI()
        else {
            return nil
        }
        authUI.providers = [
            FUIGoogleAuth(authUI: authUI),
            FUIFacebookAuth(authUI: authUI),
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
        Firebase.Auth.auth().currentUser
    }
    
    var uid: String {
        currentUser?.uid ?? ""
    }

    var authUserReference: DocumentReference? {

        guard isLoggedIn else { return nil }

        return FirestoreManager.db.collection(FIDocument.User.colletionName).document(uid)
    }

    func presentAuthViewController(from: UIViewController) {
        guard
            let authViewController = authUI?.authViewController().viewControllers.first
        else {
            return
        }
        
        let vc = RockMapNavigationController(
            rootVC: authViewController,
            naviBarClass: RockMapNavigationBar.self
        )
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        from.present(vc, animated: true)
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

        let userDocument = FIDocument.User(
            id: user.uid,
            createdAt: user.metadata.creationDate ?? Date(),
            updatedAt: nil,
            name: user.displayName ?? "-",
            photoURL: user.photoURL
        )

        userDocument.makeDocumentReference()
            .exists()
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.loginFinishedSubject.send(.failure(error))
                return Empty()
            }
            .sink { [weak self] exists in

                guard let self = self else { return }

                self.setUserDocument(exists: exists, document: userDocument)
            }
            .store(in: &bindings)
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

    private func setUserDocument(exists: Bool, document: FIDocument.User) {
        if exists {
            do {
                var updateDictionary = try document.makedictionary(shouldExcludeEmpty: true)
                updateDictionary.removeValue(forKey: "photoURL")
                updateDictionary.removeValue(forKey: "socialLinks")

                document.makeDocumentReference()
                    .updateData(updateDictionary)
                    .handleLoginResult(self.loginFinishedSubject)
                    .store(in: &self.bindings)
            } catch {
                self.loginFinishedSubject.send(.failure(error))
            }

        } else {
            document.makeDocumentReference()
                .setData(from: document)
                .handleLoginResult(self.loginFinishedSubject)
                .store(in: &self.bindings)
        }
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
            loginFinishedSubject.send(.failure(error))
            return Empty()
        }
        .sink { _ in
            loginFinishedSubject.send(.success(()))
        }
    }

}

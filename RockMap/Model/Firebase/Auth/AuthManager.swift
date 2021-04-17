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

    private override init() {
        super.init()
        authUI?.delegate = self
    }
    
    let authUI: FUIAuth? = {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.providers = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
            FUIEmailAuth()
        ]
        return authUI
    }()

    let loginFinishedPublisher: PassthroughSubject<Void, Error> = .init()
    
    var isLoggedIn: Bool {
        currentUser != nil
    }
    
    var currentUser: User? {
        Firebase.Auth.auth().currentUser
    }
    
    var uid: String {
        currentUser?.uid ?? ""
    }

    func presentAuthViewController(from: UIViewController) {
        guard
            let authViewController = authUI?.authViewController().viewControllers.first
        else {
            return
        }
        
        let vc = RockMapNavigationController(rootVC: authViewController, naviBarClass: RockMapNavigationBar.self)
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

    var authUserReference: DocumentReference {
        FirestoreManager.db.collection(FIDocument.User.colletionName).document(uid)
    }

}

extension AuthManager: FUIAuthDelegate {

    func authUI(
        _ authUI: FUIAuth,
        didSignInWith authDataResult: AuthDataResult?,
        error: Error?
    ) {
        if let error = error {
            loginFinishedPublisher.send(completion: .failure(error))
            return
        }

        guard
            let user = authDataResult?.user
        else {
            loginFinishedPublisher.send(completion: .failure(AuthError.noUser))
            return
        }

        let userDocument = FIDocument.User(
            id: user.uid,
            createdAt: user.metadata.creationDate ?? Date(),
            updatedAt: nil,
            name: user.displayName ?? "-",
            email: user.email,
            photoURL: user.photoURL
        )

        userDocument.makeDocumentReference()
            .setData(from: userDocument)
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.loginFinishedPublisher.send(completion: .finished)

                        case .failure(let error):
                            self.loginFinishedPublisher.send(completion: .failure(error))

                    }
                },
                receiveValue: {}
            )
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

}

enum AuthError: LocalizedError {
    case noUser
}

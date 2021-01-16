//
//  AuthManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/03.
//

import FirebaseUI
import Firebase

struct AuthManager {
    
    static let authUI: FUIAuth? = {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.providers = providers
        return authUI
    }()
    
    static var isLoggedIn: Bool {
        Self.currentUser != nil
    }
    
    static var currentUser: User? {
        Firebase.Auth.auth().currentUser
    }
    
    static var uid: String {
        Self.currentUser?.uid ?? ""
    }
    
    static func setDelegate(destination: UIViewController) {
        authUI?.delegate = destination as? FUIAuthDelegate
    }
    
    static func presentAuthViewController(from: UIViewController) {
        guard let authViewController = authUI?.authViewController().viewControllers.first else {
            return
        }
        let vc = RockMapNavigationController(rootVC: authViewController, naviBarClass: RockMapNavigationBar.self)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        from.present(vc, animated: true)
    }
    
    static func logout(completion: (Result<Void, Error>) -> Void) {
        do {
            try authUI?.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    static func saveAccount(uid: String) {
        KeychainDataHolder.shared.uid = uid
    }
    
    private static let providers: [FUIAuthProvider] = {
        return [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
            FUIEmailAuth()
        ]
    }()
}

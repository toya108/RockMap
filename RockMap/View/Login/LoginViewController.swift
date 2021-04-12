//
//  LoginViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/27.
//

import UIKit
import Combine
import FirebaseUI

final class LoginViewController: UIViewController {

    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var penguinImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var guestLoginButton: UIButton!

    private var bindings = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    @IBAction func didGuestLoginButtonTapped(_ sender: UIButton) {
        
        guard
            AuthManager.isLoggedIn
        else {
            
            UIApplication.shared.windows.first { $0.isKeyWindow }? .rootViewController = MainTabBarController()
            
            return
        }
        
        guard
            let userName = AuthManager.currentUser?.displayName
        else {
            return
        }
        
        var logoutHandler: (UIAlertAction) -> Void {{ _ in
            AuthManager.logout { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                    case .success:
                        break

                    case .failure(let error):
                        self.showOKAlert(
                            title: "ログアウトに失敗しました。",
                            message: "通信環境をご確認の上、再度お試し下さい。\(error.localizedDescription)"
                        )
                }
                
            }
        }}

        showAlert(
            title: "ログアウトしますか？",
            message: "こちらのユーザーでログイン中です。\n\(userName)",
            actions: [
                .init(title: "はい", style: .default, handler: logoutHandler),
                .init(title: "キャンセル", style: .cancel)
            ]
        )
    }

    @IBAction func didLoginButtonTapped(_ sender: UIButton) {
        AuthManager.presentAuthViewController(from: self)
    }
    
    private func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        
        loginContainerView.layer.cornerRadius = Resources.Const.UI.View.radius
        loginContainerView.layer.shadowColor = Resources.Const.UI.Shadow.color
        loginContainerView.layer.shadowRadius = Resources.Const.UI.Shadow.radius
        loginContainerView.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        loginContainerView.layer.shadowOffset = .init(width: 2, height: 2)
        
        penguinImageView.layer.cornerRadius = Resources.Const.UI.View.radius
        loginButton.layer.cornerRadius = Resources.Const.UI.View.radius
        guestLoginButton.layer.cornerRadius = Resources.Const.UI.View.radius
    }
}

extension LoginViewController: FUIAuthDelegate {

    // User: https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Protocols/UserInfo
    public func authUI(
        _ authUI: FUIAuth,
        didSignInWith user: User?,
        error: Error?
    ) {
        if let error = error {
            let nsError = error as NSError
            
            // Cancel
            if nsError.code == 1 { return }
            
            self.showOKAlert(title: "認証に失敗しました。", message: error.localizedDescription)
            return
        }
        
        guard let user = user else {
            self.showOKAlert(title: "認証に失敗しました。", message: "通信環境をご確認の上再度お試しください。")
            return
        }
        
        showIndicatorView()

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
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = MainTabBarController()

                        case .failure(let error):
                            self.hideIndicatorView()
                            self.showOKAlert(title: "認証に失敗しました。", message: error.localizedDescription)
                            
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

extension LoginViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

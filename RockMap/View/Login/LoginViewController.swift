//
//  LoginViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/27.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {

    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var penguinImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var guestLoginButton: UIButton!

    private var bindings = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupBindings()
    }
    
    @IBAction func didGuestLoginButtonTapped(_ sender: UIButton) {
        if AuthManager.shared.isLoggedIn {
            presentLogoutAlert()
        } else {
            UIApplication.shared.windows.first { $0.isKeyWindow }? .rootViewController = MainTabBarController()
        }
    }

    @IBAction func didLoginButtonTapped(_ sender: UIButton) {
        if AuthManager.shared.isLoggedIn {
            UIApplication.shared.windows.first { $0.isKeyWindow }? .rootViewController = MainTabBarController()
        } else {
            AuthManager.shared.presentAuthViewController(from: self)
        }
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

    private func setupBindings() {
        AuthManager.shared.loginFinishedPublisher
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = MainTabBarController()

                        case .failure(let error):
                            self.showOKAlert(title: "認証に失敗しました。", message: error.localizedDescription)

                    }
                }, receiveValue: {}
            )
            .store(in: &bindings)
    }

    private func presentLogoutAlert() {

        var logoutHandler: (UIAlertAction) -> Void {{ [weak self] _ in

            guard let self = self else { return }

            AuthManager.shared.logout()
                .sink(
                    receiveCompletion: { [weak self] result in

                        guard let self = self else { return }

                        switch  result {
                            case .finished:
                                self.showOKAlert(
                                    title: "ログアウトしました。"
                                )

                            case .failure(let error):
                                self.showOKAlert(
                                    title: "ログアウトに失敗しました。",
                                    message: "通信環境をご確認の上、再度お試し下さい。\(error.localizedDescription)"
                                )
                        }
                    },
                    receiveValue: {}
                )
                .store(in: &self.bindings)
        }}

        let message: String = {
            guard
                let userName = AuthManager.shared.currentUser?.displayName
            else {
                return ""
            }
            return "既にこちらのユーザーとしてログイン中です。\n\(userName)"
        }()

        showAlert(
            title: "ログアウトしますか？",
            message: message,
            actions: [
                .init(title: "はい", style: .default, handler: logoutHandler),
                .init(title: "キャンセル", style: .cancel)
            ]
        )
    }
}

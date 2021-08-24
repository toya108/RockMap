
import Auth
import UIKit
import Combine
import SafariServices

final class LoginViewController: UIViewController {

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

            guard
                let authViewController = AuthManager.shared.authViewController
            else {
                return
            }

            let vc = RockMapNavigationController(
                rootVC: authViewController,
                naviBarClass: RockMapNavigationBar.self
            )
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }

    @IBAction func didTermsButtonTapped(_ sender: UIButton) {
        let vc = SFSafariViewController(url: Resources.Const.Url.terms)
        self.present(vc, animated: true)
    }

    @IBAction func didPrivacyPolicyButtonTapped(_ sender: UIButton) {
        let vc = SFSafariViewController(url: Resources.Const.Url.privacyPolicy)
        self.present(vc, animated: true)
    }

    private func setupLayout() {
        navigationController?.isNavigationBarHidden = true

        loginButton.layer.cornerRadius = Resources.Const.UI.View.radius
    }

    private func setupBindings() {
        AuthManager.shared.loginFinishedPublisher
            .sink { [weak self] result in

                guard let self = self else { return }

                switch result {
                    case .success:
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = MainTabBarController()

                    case .failure(let error):
                        self.showOKAlert(
                            title: "認証に失敗しました。",
                            message: error.localizedDescription
                        )
                }
            }
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

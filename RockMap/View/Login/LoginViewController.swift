//
//  LoginViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/27.
//

import UIKit
import FirebaseUI

final class LoginViewController: UIViewController {

    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var penguinImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var guestLoginButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        AuthManager.authUI?.delegate = self
    }
    
    @IBAction func didGuestLoginButtonTapped(_ sender: UIButton) {
        UIApplication.shared.windows.first { $0.isKeyWindow }? .rootViewController = MainTabBarController()
    }

    @IBAction func didLoginButtonTapped(_ sender: UIButton) {
        AuthManager.presentAuthViewController(from: self)
    }
    
    private func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        
        loginContainerView.layer.cornerRadius = 8
        loginContainerView.layer.shadowColor = Resources.Const.UI.Shadow.color
        loginContainerView.layer.shadowRadius = Resources.Const.UI.Shadow.radius
        loginContainerView.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        loginContainerView.layer.shadowOffset = .init(width: 2, height: 2)
        
        penguinImageView.layer.cornerRadius = 8
        loginButton.layer.cornerRadius = 8
        guestLoginButton.layer.cornerRadius = 8
    }
}

extension LoginViewController: FUIAuthDelegate {
    // User: https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Protocols/UserInfo
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
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
        
        indicator.startAnimating()
        
        FirestoreManager.set(
            key: user.uid,
            FIDocument.Users(
                uid: user.uid,
                name: user.displayName ?? "-",
                email: user.email
            )
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                AuthManager.saveAccount(uid: user.uid)
                self.indicator.stopAnimating()
                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = MainTabBarController()

            case .failure(let error):
                self.indicator.stopAnimating()
                self.showOKAlert(title: "認証に失敗しました。", message: error.localizedDescription)
                
            }
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return FUICustomAuthPickerViewController(
            nibName: FUICustomAuthPickerViewController.className,
            bundle: Bundle.main,
            authUI: authUI)
    }
}

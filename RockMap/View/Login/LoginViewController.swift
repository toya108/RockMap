//
//  LoginViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/27.
//

import Combine
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var guestLoginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    private let viewModel = LoginViewModel()
    
    private var binding = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setupLayout()
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @IBAction func didGuestLoginButtonTapped(_ sender: UIButton) {
        UIApplication.shared.windows.first { $0.isKeyWindow }? .rootViewController = MainTabBarController()
    }

    @IBAction func didSignUpButtonTapped(_ sender: UIButton) {
        guard let signUpViewController = UIStoryboard(name: "SignUpViewController", bundle: nil).instantiateInitialViewController() as? SignUpViewController else { return }
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    private func setupDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        
        loginContainerView.layer.cornerRadius = 8
        loginContainerView.layer.shadowRadius = 8
        loginContainerView.layer.shadowOpacity = 0.3
        
        loginButton.layer.cornerRadius = 8
        guestLoginButton.layer.cornerRadius = 8
        signUpButton.layer.cornerRadius = 8
    }
    
    private func bindViewToViewModel() {
        emailTextField.textDidChangedPublisher.assign(to: &viewModel.$email)
        passwordTextField.textDidChangedPublisher.assign(to: &viewModel.$password)
    }
    
    private func bindViewModelToView() {
        viewModel.$emailValidationResult.sink { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .valid, .none:
                self.emailErrorLabel.isHidden = true
                
            case .invalid(let error):
                self.emailErrorLabel.text = error.description
                self.emailErrorLabel.isHidden = false
                
            }
        }
        .store(in: &binding)
        
        viewModel.$passwordValidationResult.sink { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .valid, .none:
                self.passwordErrorLabel.isHidden = true
                
            case .invalid(let error):
                self.passwordErrorLabel.text = error.description
                self.passwordErrorLabel.isHidden = false
                
            }
        }
        .store(in: &binding)
        
        viewModel.$isPassedAllValidation.sink { [weak self] isPassed in
            guard let self = self else { return }
            
            self.loginButton.isEnabled = isPassed
        }
        .store(in: &binding)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [emailTextField, passwordTextField]
        
        guard let currentTextFieldIndex = textFields.firstIndex(of: textField) else { return false }
        
        if currentTextFieldIndex + 1 == textFields.endIndex {
            textField.resignFirstResponder()
        } else {
            textFields[currentTextFieldIndex + 1]?.becomeFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//
//  SignUpViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/28.
//

import UIKit
import Combine

class SignUpViewController: UIViewController {
    @IBOutlet weak var signUpContainerView: UIView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameErrorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!

    private let viewModel = SignUpViewModel()
    private var binding = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @IBAction func didSignUpButtonTapped(_ sender: UIButton) {

    }
    
    @IBAction func didCloseButtonTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func bindViewToViewModel() {
        userNameTextField.textDidChangedPublisher.assign(to: &viewModel.$userName)
        emailTextField.textDidChangedPublisher.assign(to: &viewModel.$email)
        passwordTextField.textDidChangedPublisher.assign(to: &viewModel.$password)
        confirmPasswordTextField.textDidChangedPublisher.assign(to: &viewModel.$confirmPassword)
    }
    
    private func bindViewModelToView() {
        zip([viewModel.$userNameValidationResult,
             viewModel.$emailValidationResult,
             viewModel.$passwordValidationResult,
             viewModel.$confirmPasswordValidationResult],
            [userNameErrorLabel,
             emailErrorLabel,
             passwordErrorLabel,
             confirmPasswordErrorLabel]).forEach { viewModelResult, label in
            
            viewModelResult.sink { result in
                switch result {
                case .valid, .none:
                    label?.isHidden = true
                    
                case .invalid(let error):
                    label?.text = error.description
                    label?.isHidden = false
                    
                }
            }.store(in: &binding)
        }
        
        viewModel.$isPassedAllValidation.sink { [weak self] isPassed in
            guard let self = self else { return }
            
            self.signUpButton.isEnabled = isPassed
        }
        .store(in: &binding)
    }
    
    private func setupDelegate() {
        [userNameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
            .forEach { $0?.delegate = self }
    }
    
    private func setupLayout() {
        signUpContainerView.layer.cornerRadius = 8
        signUpContainerView.layer.shadowRadius = 8
        signUpContainerView.layer.shadowOpacity = 0.3
    
        signUpButton.layer.cornerRadius = 8
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [userNameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
        
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

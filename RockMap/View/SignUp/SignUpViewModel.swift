//
//  SignUpViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import Combine
import FirebaseAuth
import FirebaseFirestore

final class SignUpViewModel {
    
    @Published var userName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published private(set) var state: NetworkState = .standby
    @Published private(set) var userNameValidationResult: ValidationResult = .none
    @Published private(set) var emailValidationResult: ValidationResult = .none
    @Published private(set) var passwordValidationResult: ValidationResult = .none
    @Published private(set) var confirmPasswordValidationResult: ValidationResult = .none
    @Published private(set) var isPassedAllValidation = false
    
    init() {
        setupBindings()
    }

    func signUpFirebase() {
        
        state = .loading
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            FireStoreClient.db.collection("")
            if let error = error {
                self.state = .error(error)
                return
            }
            
            guard let user = authResult?.user else {
                return
            }
            
            FireStoreClient.db.collection("user")
            
            self.state = .finished(user)
        }
    }
    
    private func setupBindings() {
        $userName
            .removeDuplicates()
            .map { name -> ValidationResult in UserNameValidator().validate(name) }
            .assign(to: &$userNameValidationResult)
        
        $email
            .removeDuplicates()
            .map { email -> ValidationResult in EmailValidator().validate(email) }
            .assign(to: &$emailValidationResult)
        
        $password
            .removeDuplicates()
            .map { password -> ValidationResult in PasswordValidator().validate(password) }
            .assign(to: &$passwordValidationResult)
        
        $confirmPassword
            .removeDuplicates()
            .compactMap { [weak self] confirmPassword -> ValidationResult? in
                guard let self = self else { return nil }
                
                return ConfirmPasswordValidator(password: self.password).validate(confirmPassword)
            }
            .assign(to: &$confirmPasswordValidationResult)
        
        $userNameValidationResult
            .combineLatest($emailValidationResult, $passwordValidationResult, $confirmPasswordValidationResult)
            .map { [$0.0, $0.1, $0.2, $0.3].allSatisfy { $0.isValid } }
            .assign(to: &$isPassedAllValidation)
    }
}

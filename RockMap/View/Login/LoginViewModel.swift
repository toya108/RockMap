//
//  LoginViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import Combine
import FirebaseAuth

final class LoginViewModel {
    
    @Published var email = ""
    @Published var password = ""
    
    @Published private(set) var state: NetworkState = .standby
    @Published private(set) var emailValidationResult: ValidationResult = .none
    @Published private(set) var passwordValidationResult: ValidationResult = .none
    @Published private(set) var isPassedAllValidation = false

    private var binding = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }

    func signUpFirebase() {
        
        state = .loading
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            
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
        $email
            .dropFirst()
            .removeDuplicates()
            .map { email -> ValidationResult in EmailValidator().validate(email) }
            .assign(to: &$emailValidationResult)
        
        $password
            .dropFirst()
            .removeDuplicates()
            .map { password -> ValidationResult in PasswordValidator().validate(password) }
            .assign(to: &$passwordValidationResult)
        
        $emailValidationResult.combineLatest($passwordValidationResult)
            .map { [$0.0, $0.1].allSatisfy { $0.isValid } }
            .assign(to: &$isPassedAllValidation)
    }
}

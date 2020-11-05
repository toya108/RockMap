//
//  TextFieldValidator.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import Foundation
import MapKit
import Combine

/// バリデータープロトコル
protocol ValidatorProtocol {
    /// 検証を行います。
    /// - Parameter value: 検証する文字列
    func validate(_ value: String) -> ValidationResult
}

/// 複合バリデータープロトコル
protocol CompositeValidator: ValidatorProtocol {
    /// 検証対象のバリデーター
    var validators: [ValidatorProtocol] { get }
    /// 検証を行います。
    /// - Parameter value: 検証する文字列
    func validate(_ value: String) -> ValidationResult
}

extension CompositeValidator {
    /// 検証結果をすべて返します。
    /// - Parameter value: 検証対象
    /// - Returns: 検証結果
    func validateReturnAllReasons(_ value: String) -> [ValidationResult] {
        return validators.map { $0.validate(value) }
    }
    
    /// 検証を行って結果を返します。複数の検証に引っかかった場合は最初の一つを返します。
    /// - Parameter value: 検証対象
    /// - Returns: 検証結果
    func validate(_ value: String) -> ValidationResult {
        let results = validators.map { $0.validate(value) }
        
        return results.first { result -> Bool in
            switch result {
            case .valid:
                return false
                
            case .invalid, .none:
                return true
                
            }
        } ?? .valid
    }
}

// MARK: - ValidationEnumeration

enum ValidationResult {
    case none
    case valid
    case invalid(ValidationError)
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
            
        case .invalid, .none:
            return false
        }
    }
    
    var error: ValidationError? {
        
        guard case .invalid(let error) = self else { return nil }
        
        return error
    }
}

enum ValidationError: Error {
    case empty(formName: String)
    case length(formName: String, min: Int?)
    case hasBlank
    case invalidEmailForm
    case unmatchConfirmPassword
    
    var description: String {
        switch self {
        case .empty(let formName):
            return "\(formName)を入力してください。"
            
        case .length(let formName, let min):
            var errorMessage = "\(formName)は"
            if let min = min { errorMessage += "\(min)文字以上" }
            return errorMessage + "で入力してください。"
            
        case .invalidEmailForm:
            return "不正な形式のメールアドレスです。"
            
        case .unmatchConfirmPassword:
            return "パスワードと確認用パスワードが一致しません。"
            
        case .hasBlank:
            return "先頭か末尾に空白が含まれています。"
            
        }
    }
}

// MARK: - CompositeValidatorStruct

/// ユーザー名検証用バリデーター
struct UserNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "ユーザー名"),
    ]
}

/// メールアドレス検証用バリデーター
struct EmailValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "メールアドレス"),
        LengthValidator(formName: "メールアドレス", min: 6),
        EmailFormValidator()
    ]
}

/// パスワード検証用バリデーター
struct PasswordValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "パスワード"),
        LengthValidator(formName: "パスワード", min: 6)
    ]
}

/// 確認用パスワード検証用バリデーター
struct ConfirmPasswordValidator: CompositeValidator {
    let password: String
    var validators: [ValidatorProtocol]
    
    init(password: String) {
        self.password = password
        validators = [EmptyValidator(formName: "確認用パスワード"),
                      LengthValidator(formName: "確認用パスワード", min: 6),
                      MatchPasswordValidator(password: password)]
    }
}

/// 岩名検証用バリデーター
struct RockNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "岩の名前")
    ]
}

// MARK: - ValidatorStruct

/// 未入力検証用バリデーター
private struct EmptyValidator: ValidatorProtocol {
    let formName: String
    
    func validate(_ value: String) -> ValidationResult {
        return value.isEmpty ? .invalid(.empty(formName: formName)) : .valid
    }
}

/// 文字の長さ検証用バリデーター
private struct LengthValidator: ValidatorProtocol {
    let formName: String
    let min: Int
    
    func validate(_ value: String) -> ValidationResult {
        let isShortLength = min > value.count
        return isShortLength ? .invalid(.length(formName: formName, min: min)) : .valid
    }
}

struct HasBlankValidator: ValidatorProtocol {
    let form: String
    
    func validate(_ value: String) -> ValidationResult {
        return (form.last?.isBlank ?? false) ? .invalid(.hasBlank) : .valid
    }
}

/// メールアドレスの形式検証用バリデーター
private struct EmailFormValidator: ValidatorProtocol {
    let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    
    func validate(_ value: String) -> ValidationResult {
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: value) ? .valid : .invalid(.invalidEmailForm)
    }
}

/// パスワードと確認用パスワードの一致確認用バリデーター
private struct MatchPasswordValidator: ValidatorProtocol {
    let password: String
    
    func validate(_ value: String) -> ValidationResult {
        return password == value ? .valid : .invalid(.unmatchConfirmPassword)
    }
}


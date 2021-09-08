import Combine
import Foundation
import MapKit

protocol ValidatorProtocol {
    func validate(_ value: Any?) -> ValidationResult
}

protocol CompositeValidator: ValidatorProtocol {
    var validators: [ValidatorProtocol] { get }

    func validate(_ value: Any?) -> ValidationResult
}

extension CompositeValidator {
    func validateReturnAllReasons(_ value: Any?) -> [ValidationResult] {
        validators.map { $0.validate(value) }
    }

    func validate(_ value: Any?) -> ValidationResult {
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
        guard case let .invalid(error) = self else { return nil }

        return error
    }
}

enum ValidationError: Error, Hashable {
    case empty(formName: String)
    case quantity(formName: String, max: Int)
    case none(formName: String)
    case length(formName: String, min: Int?)
    case cannotConvertAddressToLocation
    case cannotConvertLocationToAddrress

    var description: String {
        switch self {
        case let .empty(formName):
            return "\(formName)を入力してください。"

        case let .length(formName, min):
            var errorMessage = "\(formName)は"
            if let min = min { errorMessage += "\(min)文字以上" }
            return errorMessage + "で入力してください。"

        case .cannotConvertAddressToLocation:
            return "住所から位置情報の変換に失敗しました。"

        case .cannotConvertLocationToAddrress:
            return "位置情報から住所への変換に失敗しました。"

        case let .quantity(formName, max):
            return "\(formName)が\(max)個以上選択されています。\(formName)は\(max)個までしか選択できないため、お手数ですが再度\(max)個以下の個数を選択し直して下さい。"

        case let .none(formName):
            return "\(formName)が未選択になっています。\(formName)を選択して下さい。"
        }
    }
}

// MARK: - CompositeValidatorStruct

struct RockNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "岩の名前"),
    ]
}

struct RockAddressValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "岩の住所"),
    ]
}

struct RockImageValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        QuantityValidator(formName: "画像", max: 10),
    ]
}

struct HeaderImageValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        HeaderValidator(formName: "ヘッダー画像"),
    ]
}

struct CourseNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "課題名"),
    ]
}

struct UserNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "ユーザー名"),
    ]
}

// MARK: - ValidatorStruct

/// 未入力検証用バリデーター
private struct EmptyValidator: ValidatorProtocol {
    let formName: String

    func validate(_ value: Any?) -> ValidationResult {
        guard
            let strings = value as? String
        else {
            return .invalid(.empty(formName: self.formName))
        }

        return strings.isEmpty ? .invalid(.empty(formName: self.formName)) : .valid
    }
}

private struct HeaderValidator: ValidatorProtocol {
    let formName: String

    func validate(_ value: Any?) -> ValidationResult {
        guard
            let crudableImage = value as? CrudableImage
        else {
            return .invalid(.none(formName: self.formName))
        }

        if crudableImage.image.url == nil {
            return crudableImage.updateData == nil
                ? .invalid(.none(formName: self.formName))
                : .valid
        } else {
            return crudableImage.shouldDelete
                ? .invalid(.none(formName: self.formName))
                : .valid
        }
    }
}

/// nil検証用バリデーター
private struct NoneValidator: ValidatorProtocol {
    let formName: String

    func validate(_ value: Any?) -> ValidationResult {
        value == nil ? .invalid(.none(formName: self.formName)) : .valid
    }
}

/// 個数検証用バリデーター
private struct QuantityValidator: ValidatorProtocol {
    let formName: String
    let max: Int

    func validate(_ value: Any?) -> ValidationResult {
        guard
            let array = value as? [Any]
        else {
            return .invalid(.quantity(formName: self.formName, max: self.max))
        }

        return array.count > self.max
            ? .invalid(.quantity(formName: self.formName, max: self.max))
            : .valid
    }
}

/// 文字の長さ検証用バリデーター
private struct LengthValidator: ValidatorProtocol {
    let formName: String
    let min: Int

    func validate(_ value: Any?) -> ValidationResult {
        guard
            let strings = value as? String
        else {
            return .invalid(.empty(formName: self.formName))
        }

        return self.min > strings.count
            ? .invalid(.length(formName: self.formName, min: self.min))
            : .valid
    }
}

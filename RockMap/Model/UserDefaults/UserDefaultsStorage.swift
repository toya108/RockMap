//
//  UserDefaultsStorage.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/20.
//

import Foundation

protocol UserDefaultConvertible {
    init?(with object: Any)
    func object() -> Any?
}

class UserDefaultTypedKeys {
    init() {}
}

class UserDefaultTypedKey<T>: UserDefaultTypedKeys {
    let key: String

    init(_ key: String) {
        self.key = key
        super.init()
    }
}

extension UserDefaultTypedKeys {
    static let bookMarkedCourseIDs = UserDefaultTypedKey<Array<String>>("bookMarkedCourseIDs")
}

@propertyWrapper
struct UserDefaultsStorage<T: UserDefaultConvertible> {
    let typedKey: UserDefaultTypedKey<T>
    let defaultValue: T

    init(_ typedKey: UserDefaultTypedKey<T>, defaultValue: T) {
        self.typedKey = typedKey
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            if
                let object = UserDefaults.standard.object(forKey: self.typedKey.key),
                let value = T(with: object)
            {
                return value
            } else {
                return self.defaultValue
            }
        } set {
            if let object = newValue.object() {
                UserDefaults.standard.set(object, forKey: self.typedKey.key)
            } else {
                UserDefaults.standard.removeObject(forKey: self.typedKey.key)
            }
        }
    }
}

extension String: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? String else {
            return nil
        }
        self = value
    }

    func object() -> Any? {
        return self
    }
}

extension Array: UserDefaultConvertible where Element: UserDefaultConvertible {
    private struct Error: Swift.Error {}

    init?(with object: Any) {
        
        guard
            let array = object as? [Any]
        else {
            return nil
        }

        guard let value = try? array.map({ (object) -> Element in
            if let element = Element(with: object) {
                return element
            } else {
                throw Error()
            }
        }) else {
            return nil
        }

        self = value
    }

    func object() -> Any? {
        return try? self.map { (element) -> Any in
            if let object = element.object() {
                return object
            } else {
                throw Error()
            }
        }
    }
}

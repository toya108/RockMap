//
//  File.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/03.
//

import KeychainAccess

@propertyWrapper
class KeychainStorage<T: LosslessStringConvertible> {

    private let key: String

    var keychain: Keychain {
        guard let identifier = Bundle.main.object(forInfoDictionaryKey: UUID().uuidString) as? String else {
            return Keychain(service: "")
        }
        return Keychain(service: identifier)
    }
    
    init(key: String) {
        self.key = key
    }

    var wrappedValue: T? {
        get {
            do {
                guard let result = try keychain.get(key) else { return nil }
                return T(result)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        set {
            do {
                guard let new = newValue else {
                    try keychain.remove(key)
                    return
                }
                try keychain.set(String(new), key: key)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}

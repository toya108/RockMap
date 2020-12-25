//
//  KeychainDataHolder.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/03.
//

import Foundation

final class KeychainDataHolder {
    
    private enum Key: String {
        case uid = "_uid"
    }

    static let shared: KeychainDataHolder = KeychainDataHolder()

    private init() {}

    @KeychainStorage(key: Key.uid.rawValue)
    var uid: String?

    func removeAllKeychainData() {
        uid = nil
    }
}

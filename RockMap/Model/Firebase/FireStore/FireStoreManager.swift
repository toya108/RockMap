//
//  FireStoreManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import FirebaseFirestore

struct FirestoreManager {
    static let db = Firestore.firestore()
    static let encoder = Firestore.Encoder()
    static let decoder = Firestore.Decoder()

    typealias Value = FieldValue
}

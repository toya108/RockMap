//
//  FireStoreClient.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/26.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

final class FireStoreClient {
    
    static let db = Firestore.firestore()
    
    private init() {}
}

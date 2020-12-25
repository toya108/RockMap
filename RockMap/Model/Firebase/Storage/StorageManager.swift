//
//  StorageManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/17.
//

import FirebaseStorage

struct StorageManager {
    static let reference = Storage.storage().reference()
    
    static func makeReference(parent: FINameSpaceProtocol.Type, child: String) -> StorageReference {
        Self.reference.child(parent.name).child(child)
    }
}

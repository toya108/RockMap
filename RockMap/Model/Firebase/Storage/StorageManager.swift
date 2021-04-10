//
//  StorageManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/17.
//

import FirebaseStorage
import Combine

struct StorageManager {
    
    typealias Reference = StorageReference
    
    static let reference = Storage.storage().reference()
    
    static func makeReference(
        parent: FINameSpaceProtocol.Type,
        child: String
    ) -> StorageReference {
        Self.reference
            .child(parent.name)
            .child(child)
    }

    static func makeHeaderImageReference(
        parent: FINameSpaceProtocol.Type,
        child: String
    ) -> StorageReference {
        Self.reference
            .child(parent.name)
            .child(child)
            .child(ImageType.header.typeName)
            .child(UUID().uuidString)
    }

    static func makeNormalImageReference(
        parent: FINameSpaceProtocol.Type,
        child: String
    ) -> StorageReference {
        Self.reference
            .child(parent.name)
            .child(child)
            .child(ImageType.normal.typeName)
            .child(AuthManager.uid)
            .child(UUID().uuidString)
    }
    
    static func getHeaderReference(
        _ reference: StorageReference
    ) -> AnyPublisher<StorageReference?, Error> {

        let headerReference = reference.child(ImageType.header.typeName)

        return headerReference.getReference()
    }

    static func getNormalReference(
        _ reference: StorageReference
    ) -> AnyPublisher<[StorageReference], Error> {

        let headerReference = reference.child(ImageType.normal.typeName)

        return headerReference.getReferences()
    }
}

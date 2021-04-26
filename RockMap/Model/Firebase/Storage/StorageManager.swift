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
        path: String
    ) -> StorageReference {
        Self.reference.child(path)
    }
    
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
            .child(AuthManager.shared.uid)
            .child(UUID().uuidString)
    }

    static func getReference(
        _ reference: StorageReference
    ) -> AnyPublisher<[StorageReference], Error> {
        return reference.getReferences()
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
        return reference.child(ImageType.normal.typeName).getReferences()
    }

    static func getNormalImagePrefixes(
        _ reference: StorageReference
    ) -> AnyPublisher<[StorageReference], Error> {
        return reference.child(ImageType.normal.typeName).getPrefixes()
    }

    static func deleteReference<T: FIDocumentProtocol>(
        _ documentType: T.Type,
        id: String
    ) {
        Self.reference
            .child(documentType.colletionName)
            .child(id)
            .delete(completion: { _ in })
    }
}

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

    static func makeImageReferenceForUpload(
        destinationDocument: FINameSpaceProtocol.Type,
        documentId: String,
        imageType: ImageType
    ) -> StorageReference {
        let reference = Self.reference
            .child(destinationDocument.name)
            .child(documentId)
            .child(imageType.typeName)

        switch imageType {
            case .header:
                return reference.child(UUID().uuidString)

            case .normal:
                return reference
                    .child(AuthManager.shared.uid)
                    .child(UUID().uuidString)
        }
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

struct UpdatableStorage: Hashable {
    let storageReference: StorageReference
    var shouldUpdate: Bool = false
    var updateData: Data?
}

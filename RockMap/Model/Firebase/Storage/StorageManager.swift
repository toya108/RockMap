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
        destinationDocument: FINameSpaceProtocol.Type,
        documentId: String
    ) -> AnyPublisher<StorageReference?, Error> {
        return makeReference(
            parent: destinationDocument,
            child: documentId
        )
        .child(ImageType.header.typeName)
        .getReference()
    }

    static func getNormalReference(
        destinationDocument: FINameSpaceProtocol.Type,
        documentId: String
    ) -> AnyPublisher<[StorageReference], Error> {
        return makeReference(
            parent: destinationDocument,
            child: documentId
        )
        .child(ImageType.normal.typeName)
        .getReferences()
    }

    static func getNormalImagePrefixes(
        destinationDocument: FINameSpaceProtocol.Type,
        documentId: String
    ) -> AnyPublisher<[StorageReference], Error> {
        return makeReference(
            parent: destinationDocument,
            child: documentId
        )
        .child(ImageType.normal.typeName)
        .getPrefixes()
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

    static private func makeReference(
        parent: FINameSpaceProtocol.Type,
        child: String
    ) -> StorageReference {
        Self.reference
            .child(parent.name)
            .child(child)
    }
}

struct UpdatableStorage: Hashable {
    let storageReference: StorageReference
    var shouldUpdate: Bool = false
    var updateData: Data?
}

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
    
    static let storage = Storage.storage()

    static func makeImageReferenceForUpload(
        destinationDocument: FINameSpaceProtocol.Type,
        documentId: String,
        imageType: ImageType
    ) -> StorageReference {
        let reference = Self.storage.reference()
            .child(destinationDocument.name)
            .child(documentId)
            .child(imageType.typeName)

        switch imageType {
            case .header, .icon:
                return reference.child(UUID().uuidString)

            case .normal:
                return reference
                    .child(AuthManager.shared.uid)
                    .child(UUID().uuidString)
        }
    }

    static func getReference(
        destinationDocument: FINameSpaceProtocol.Type,
        documentId: String,
        imageType: ImageType
    ) -> AnyPublisher<StorageReference?, Error> {
        return makeReference(
            parent: destinationDocument,
            child: documentId
        )
        .child(imageType.typeName)
        .getReference()
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
        Self.storage.reference()
            .child(documentType.colletionName)
            .child(id)
            .delete(completion: { _ in })
    }

    static private func makeReference(
        parent: FINameSpaceProtocol.Type,
        child: String
    ) -> StorageReference {
        Self.storage.reference()
            .child(parent.name)
            .child(child)
    }
}


struct UpdatableStorage: Hashable {
    let storageReference: StorageReference
    var shouldDelete: Bool = false
    var updateData: Data?
}

struct CrudableImage<D: FIDocumentProtocol>: Hashable {
    var storageReference: StorageReference?
    var updateData: Data?
    var shouldDelete: Bool = false
    let imageType: ImageType

    func makeImageReference(documentId: String) -> StorageReference {
        return StorageManager.makeImageReferenceForUpload(
            destinationDocument: D.Collection.self,
            documentId: documentId,
            imageType: imageType
        )
    }
}

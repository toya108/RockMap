//
//  CrudableImage.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/07/07.
//

import Foundation

struct CrudableImage: Hashable {
    var storageReference: StorageManager.Reference?
    var updateData: Data?
    var shouldDelete: Bool = false
    let imageType: ImageType

    func makeImageReference(documentId: String, documentType: FINameSpaceProtocol.Type) -> StorageManager.Reference {
        return StorageManager.makeImageReferenceForUpload(
            destinationDocument: documentType,
            documentId: documentId,
            imageType: imageType
        )
    }
}

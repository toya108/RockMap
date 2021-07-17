//
//  CrudableImage.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/07/07.
//

import Foundation

struct CrudableImage<D: FIDocumentProtocol>: Hashable {
    var storageReference: StorageManager.Reference?
    var updateData: Data?
    var shouldDelete: Bool = false
    let imageType: ImageType

    func makeImageReference(documentId: String) -> StorageManager.Reference {
        return StorageManager.makeImageReferenceForUpload(
            destinationDocument: D.Collection.self,
            documentId: documentId,
            imageType: imageType
        )
    }
}

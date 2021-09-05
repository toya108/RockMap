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

struct CrudableImageV2: Hashable {
    var updateData: Data?
    var shouldDelete: Bool = false
    let image: Entity.Image

    init(imageType: Entity.Image.ImageType) {
        self.updateData = nil
        self.shouldDelete = false
        self.image = .init(imageType: imageType)
    }

    init(
        updateData: Data? = nil,
        shouldDelete: Bool = false,
        image: Entity.Image
    ) {
        self.updateData = updateData
        self.shouldDelete = shouldDelete
        self.image = image
    }
//
//    func addImage(
//        set: 
//    ) {
//        if shouldDelete, let storage = image.storageReference {
//            storage.delete(completion: { _ in })
//            return
//        }
//
//        if let storage = image.storageReference, let data = image.updateData {
//            addData(data: data, reference: storage)
//            return
//        }
//
//        if let data = image.updateData {
//            let reference = image.makeImageReference(documentId: id, documentType: documentType)
//            addData(data: data, reference: reference)
//            return
//        }
//    }
}

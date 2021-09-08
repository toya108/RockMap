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
    var imageType: Entity.Image.ImageType
    let image: Entity.Image

    init(imageType: Entity.Image.ImageType) {
        self.updateData = nil
        self.shouldDelete = false
        self.image = .init()
        self.imageType = imageType
    }

    init(
        updateData: Data? = nil,
        shouldDelete: Bool = false,
        imageType: Entity.Image.ImageType,
        image: Entity.Image
    ) {
        self.updateData = updateData
        self.shouldDelete = shouldDelete
        self.imageType = imageType
        self.image = image
    }
}

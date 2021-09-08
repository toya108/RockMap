
import Foundation

struct CrudableImage: Hashable {
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

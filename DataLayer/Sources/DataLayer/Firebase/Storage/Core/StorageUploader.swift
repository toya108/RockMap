import Combine
import FirebaseStorage

class StorageUploader {
    private struct Component {
        var file: URL?
        var data: Data?
        var reference: StorageReference
        var metadata: StorageMetadata?
        var isComplete = false
    }

    struct UnitCount {
        let total: Int64
        let completed: Int64
    }

    enum UploadState {
        case stanby
        case progress(UnitCount)
        case complete([StorageMetadata])
        case failure(Error)
    }

    private var components = [Component]()
    private var uploadTasks = [StorageUploadTask]()
    private var totalUnitCount: Int64 = 1
    private var completedUnitCount: Int64 = 0

    @Published var uploadState: UploadState = .stanby

    //    func addData(image: CrudableImage, id: String, documentType: FINameSpaceProtocol.Type) {
    //
    //        if image.shouldDelete, let storage = image.storageReference {
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

    func addComponet(
        file: URL,
        reference: StorageReference,
        metadata: StorageMetadata
    ) {
        metadata.cacheControl = "no-cache"
        let component = Component(
            file: file,
            data: nil,
            reference: reference,
            metadata: metadata,
            isComplete: false
        )
        components.append(component)
    }

    func addData(
        data: Data,
        reference: StorageReference,
        metadata: StorageMetadata = .init()
    ) {
        metadata.cacheControl = "no-cache"
        let component = Component(
            file: nil,
            data: data,
            reference: reference,
            metadata: metadata,
            isComplete: false
        )
        components.append(component)
    }

    func start() {
        if self.components.isEmpty {
            self.uploadState = .complete([])
        } else {
            self.prepareUpload()
            self.uploadState = .progress(
                .init(
                    total: self.totalUnitCount,
                    completed: self.completedUnitCount
                )
            )
        }
    }

    private func prepareUpload() {
        self.components.enumerated().forEach { index, component in

            let reference = component.reference
            let metadata = component.metadata

            if let file = component.file {
                observeStatus(
                    reference.putFile(from: file, metadata: metadata),
                    total: components.count,
                    index: index
                )
                return
            }

            if let data = component.data {
                observeStatus(
                    reference.putData(data, metadata: metadata),
                    total: components.count,
                    index: index
                )
                return
            }
        }
    }

    private func observeStatus(
        _ uploadTask: StorageUploadTask,
        total: Int,
        index: Int
    ) {
        self.uploadTasks.append(uploadTask)

        uploadTask.observe(.progress) { [weak self] _ in

            guard let self = self else { return }

            var currentCompletedUnitCount: Int64 = 0
            var currentTotalUnitCount: Int64 = 0

            self.uploadTasks.forEach { uploadTask in
                currentCompletedUnitCount += uploadTask.snapshot.progress?.completedUnitCount ?? 0
                currentTotalUnitCount += (uploadTask.snapshot.progress?.totalUnitCount ?? 0)
            }

            self.completedUnitCount = currentCompletedUnitCount
            self.totalUnitCount = currentTotalUnitCount

            self.uploadState = .progress(
                .init(
                    total: currentTotalUnitCount,
                    completed: currentCompletedUnitCount
                )
            )
        }

        uploadTask.observe(.success) { [weak self] _ in

            guard let self = self else { return }

            guard
                total == index + 1
            else {
                return
            }

            let metaDatas = self.uploadTasks.map { uploadTask -> StorageMetadata in
                uploadTask.snapshot.metadata ?? StorageMetadata()
            }
            self.uploadState = .complete(metaDatas)
        }

        uploadTask.observe(.failure) { [weak self] snapshot in

            guard let self = self else { return }

            self.uploadTasks.forEach {
                if $0.snapshot.progress?.isCancellable ?? false {
                    $0.cancel()
                }
            }

            if let error = snapshot.error {
                self.uploadState = .failure(error)
            }
        }
    }
}

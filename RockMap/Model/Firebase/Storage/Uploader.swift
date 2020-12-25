//
//  Uploader.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/20.
//

import FirebaseStorage
import Combine

class StorageUploader {
    
    private struct Component {
        var file: URL?
        var data: Data?
        var reference: StorageReference?
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

    func addComponet(
        file: URL,
        reference: StorageReference,
        metadata: StorageMetadata
    ) {
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
        metadata: StorageMetadata? = nil
    ) {
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
        prepareUpload()
        uploadState = .progress(
            .init(
                total: totalUnitCount,
                completed: completedUnitCount
            )
        )
    }

    private func prepareUpload() {
        components.forEach { component in
            
            let reference = component.reference
            let metadata = component.metadata
            
            if
                let file = component.file,
                let uploadTask = reference?.putFile(from: file, metadata: metadata)
            {
                observeStatus(uploadTask)
                return
            }
            
            if
                let data = component.data,
                let uploadTask = reference?.putData(data, metadata: metadata)
            {
                observeStatus(uploadTask)
                return
            }
        }
    }

    private func observeStatus(_ uploadTask: StorageUploadTask) {
        
        uploadTasks.append(uploadTask)
        
        uploadTask.observe(.progress) { [weak self] snapshot in
            
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
        
        uploadTask.observe(.success) { [weak self] snapshot in
            
            guard let self = self else { return }
            
            guard self.completedUnitCount == self.totalUnitCount else { return }
            
            let metaDatas = self.uploadTasks.map { uploadTask -> StorageMetadata in
                return uploadTask.snapshot.metadata ?? StorageMetadata()
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

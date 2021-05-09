//
//  RockConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import CoreLocation
import Combine
import FirebaseFirestore

protocol RockConfirmViewModelModelProtocol: ViewModelProtocol {
    var input: RockConfirmViewModel.Input { get }
    var output: RockConfirmViewModel.Output { get }
}

final class RockConfirmViewModel: RockConfirmViewModelModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    let registerType: RockRegisterViewModel.RegisterType
    let rockDocument: FIDocument.Rock
    let header: ImageDataKind
    let images: [ImageDataKind]

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()

    init(
        registerType: RockRegisterViewModel.RegisterType,
        rockDocument: FIDocument.Rock,
        header: ImageDataKind,
        images: [ImageDataKind]
    ) {
        self.registerType = registerType
        self.rockDocument = rockDocument
        self.header = header
        self.images = images
        bindImageUploader()
        bindInput()
    }

    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &output.$imageUploadState)
    }

    private func bindInput() {
        input.uploadImageSubject
            .sink(receiveValue: uploadImages)
            .store(in: &bindings)

        input.registerCourseSubject
            .sink(receiveValue: registerCourse)
            .store(in: &bindings)
    }

    private func uploadImages() {
        prepareHeaderUploading()
        prepareImagesUploading()
        uploader.start()
    }

    private func prepareHeaderUploading() {
        switch header {
            case .data(let data):
                uploader.addData(
                    data: data.data,
                    reference: StorageManager.makeHeaderImageReference(
                        parent: FINameSpace.Rocks.self,
                        child: rockDocument.id
                    )
                )
            case .storage(let storage):

                guard let updateData = storage.updateData else { return }

                storage.storageReference.delete()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: {}
                    )
                    .store(in: &bindings)

                uploader.addData(
                    data: updateData,
                    reference: StorageManager.makeHeaderImageReference(
                        parent: FINameSpace.Rocks.self,
                        child: rockDocument.id
                    )
                )
        }
    }

    private func prepareImagesUploading() {
        images.forEach { imageDataKind in
            switch imageDataKind {
                case .data(let data):
                    uploader.addData(
                        data: data.data,
                        reference: StorageManager.makeNormalImageReference(
                            parent: FINameSpace.Rocks.self,
                            child: rockDocument.id
                        )
                    )
                case .storage(let storage):

                    guard storage.shouldUpdate else { return }

                    storage.storageReference.delete()
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: {}
                        )
                        .store(in: &bindings)
            }
        }
    }

    private func registerCourse() {
        output.rockUploadState = .loading

        switch registerType {
            case .create:
                createCourse()

            case .edit:
                editCourse()
        }
    }

    private func createCourse() {
        let badge = FirestoreManager.db.batch()

        let courseDocumentReference = rockDocument.makeDocumentReference()
        badge.setData(rockDocument.dictionary, forDocument: courseDocumentReference)

        let totalClimbedNumber = FIDocument.TotalClimbedNumber(
            parentCourseReference: rockDocument.makeDocumentReference(),
            parentPath: courseDocumentReference.path
        )
        badge.setData(totalClimbedNumber.dictionary, forDocument: totalClimbedNumber.makeDocumentReference())

        badge.commit()
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.output.rockUploadState = .finish(content: ())

                        case let .failure(error):
                            self.output.rockUploadState = .failure(error)

                    }
                }, receiveValue: {}
            )
            .store(in: &bindings)
    }

    private func editCourse() {
        rockDocument.makeDocumentReference()
            .updateData(rockDocument.dictionary)
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case .finished:
                            self.output.rockUploadState = .finish(content: ())

                        case let .failure(error):
                            self.output.rockUploadState = .failure(error)

                    }
                }, receiveValue: {}
            )
            .store(in: &bindings)
    }
}

extension RockConfirmViewModel {

    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerCourseSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var rockUploadState: LoadingState<Void> = .stanby
    }
}

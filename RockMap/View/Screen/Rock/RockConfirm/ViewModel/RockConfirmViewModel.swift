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
    var rockDocument: FIDocument.Rock
    let header: CrudableImage
    let images: [CrudableImage]

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()

    init(
        registerType: RockRegisterViewModel.RegisterType,
        rockDocument: FIDocument.Rock,
        header: CrudableImage,
        images: [CrudableImage]
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

        input.registerRockSubject
            .sink(receiveValue: registerRock)
            .store(in: &bindings)
    }

    private func uploadImages() {
        uploader.addData(image: header, id: rockDocument.id, documentType: FINameSpace.Rocks.self)
        images.forEach { uploader.addData(image: $0, id: rockDocument.id, documentType: FINameSpace.Rocks.self) }
        uploader.start()
    }

    private func registerRock() {
        output.rockUploadState = .loading

        switch registerType {
            case .create:
                createRock()

            case .edit:
                editRock()
        }
    }

    private func createRock() {
        rockDocument
            .makeDocumentReference()
            .setData(from: rockDocument)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.rockUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.rockUploadState = .finish(content: ())
            }
            .store(in: &bindings)
    }

    private func editRock() {
        rockDocument
            .makeDocumentReference()
            .updateData(rockDocument.dictionary)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                self.output.rockUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.rockUploadState = .finish(content: ())
            }
            .store(in: &bindings)
    }
}

extension RockConfirmViewModel {

    struct Input {
        let uploadImageSubject = PassthroughSubject<Void, Never>()
        let registerRockSubject = PassthroughSubject<Void, Never>()
    }

    final class Output {
        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var rockUploadState: LoadingState<Void> = .stanby
    }
}

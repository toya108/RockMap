//
//  EditProfileViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/10.
//


import Combine
import Foundation

protocol EditProfileViewModelProtocol: ViewModelProtocol {
    var input: EditProfileViewModel.Input { get }
    var output: EditProfileViewModel.Output { get }
}

class EditProfileViewModel: EditProfileViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()
    let user: FIDocument.User

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()

    init(user: FIDocument.User) {
        self.user = user
        bindInput()
        bindOutput()

        input.nameSubject.send(user.name)
        input.introductionSubject.send(user.introduction)
        fetchHeaderStorage()
        user.socialLinks.forEach {
            input.socialLinkSubject.send($0)
        }
    }

    private func bindInput() {
        input.nameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$name)

        input.introductionSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$introduction)

        input.setImageSubject
            .sink(receiveValue: setHeaderImage)
            .store(in: &bindings)

        input.deleteImageSubject
            .sink(receiveValue: deleteImage)
            .store(in: &bindings)
    }

    private func bindOutput() {
        uploader.$uploadState
            .assign(to: &output.$imageUploadState)

        output.$name
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &output.$nameValidationResult)
    }

    private func fetchHeaderStorage() {
        let userStorageReference = StorageManager.makeReference(
            parent: FINameSpace.Users.self,
            child: user.id
        )

        StorageManager
            .getHeaderReference(userStorageReference)
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .map {
                if let header = $0 {
                    return ImageDataKind.storage(.init(storageReference: header))
                } else {
                    return nil
                }
            }
            .assign(to: &output.$header)
    }

    private func setHeaderImage(kind: ImageDataKind) {
        switch output.header {
            case .data, .none:
                output.header = kind

            case .storage(var storage):
                storage.updateData = kind.data?.data
                storage.shouldUpdate = true
                output.header?.update(.storage(storage))
        }
    }

    private func deleteImage(_ imageStructure: ImageDataKind) {
        switch output.header {
            case .data:
                output.header = nil

            case .storage:
                output.header?.toggleStorageUpdateFlag()

            default:
                break
        }
    }

    func callValidations() -> Bool {
        if !output.nameValidationResult.isValid {
            output.nameValidationResult = UserNameValidator().validate(output.name)
        }
        return [
            output.nameValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }

    func uploadImage() {
        switch output.header {
            case .data(let data):
                uploader.addData(
                    data: data.data,
                    reference: StorageManager.makeHeaderImageReference(
                        parent: FINameSpace.Users.self,
                        child: user.id
                    )
                )
            case .storage(let storage):
                storage.storageReference.delete()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: {}
                    )
                    .store(in: &bindings)

                guard
                    let updateData = storage.updateData
                else {
                    output.imageUploadState = .complete([])
                    return
                }

                uploader.addData(
                    data: updateData,
                    reference: StorageManager.makeHeaderImageReference(
                        parent: FINameSpace.Users.self,
                        child: user.id
                    )
                )
            case .none:
                output.imageUploadState = .complete([])
                return

        }
        uploader.start()
    }

    func editProfile() {

        output.loadingState = .loading

        var updateUserDocument: FIDocument.User {
            var updateUser = user
            updateUser.name = output.name
            updateUser.introduction = output.introduction
            updateUser.socialLinks = output.socialLinks
            return updateUser
        }
        updateUserDocument.makeDocumentReference()
            .setData(from: updateUserDocument)
            .sinkState { [weak self] state in
                self?.output.loadingState = state
            }
            .store(in: &bindings)
    }
}

extension EditProfileViewModel {

    struct Input {
        let nameSubject = PassthroughSubject<String?, Never>()
        let introductionSubject = PassthroughSubject<String?, Never>()
        let setImageSubject = PassthroughSubject<(ImageDataKind), Never>()
        let deleteImageSubject = PassthroughSubject<(ImageDataKind), Never>()
        let socialLinkSubject = PassthroughSubject<FIDocument.User.SocialLink, Never>()
    }

    final class Output {
        @Published var name = ""
        @Published var introduction = ""
        @Published var header: ImageDataKind?
        @Published var socialLinks: Set<FIDocument.User.SocialLink> = []
        @Published var nameValidationResult: ValidationResult = .none
        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var loadingState: LoadingState<Void> = .stanby
    }
}

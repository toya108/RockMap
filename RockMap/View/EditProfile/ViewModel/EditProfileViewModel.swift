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
        fetchImageStorage()
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
            .sink(receiveValue: setImage)
            .store(in: &bindings)

        input.deleteImageSubject
            .sink(receiveValue: deleteImage)
            .store(in: &bindings)

        input.socialLinkSubject
            .sink { [weak self] socialLink in

                guard
                    let self = self,
                    let index = self.output.socialLinks.firstIndex(
                        where: { $0.linkType == socialLink.linkType }
                    )
                else {
                    return
                }

                self.output.socialLinks[index].link = socialLink.link
            }
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

    private func fetchImageStorage() {
        StorageManager
            .getReference(
                destinationDocument: FINameSpace.Users.self,
                documentId: user.id,
                imageType: .header
            )
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

        StorageManager
            .getReference(
                destinationDocument: FINameSpace.Users.self,
                documentId: user.id,
                imageType: .icon
            )
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .map {
                if let icon = $0 {
                    return .content(.storage(.init(storageReference: icon)))
                } else {
                    return .empty
                }
            }
            .assign(to: &output.$icon)
    }

    private func setImage(imageType: ImageType, kind: ImageDataKind) {
        switch imageType {
            case .icon:
                switch output.icon.content {
                    case .data, .none:
                        output.icon = .content(kind)

                    case .storage(let storage):
                        output.icon = .content(.storage(
                            .init(
                                storageReference: storage.storageReference,
                                shouldUpdate: true,
                                updateData: kind.data?.data
                            )
                        ))
                }

            case .header:
                switch output.header {
                    case .data, .none:
                        output.header = kind

                    case .storage(var storage):
                        storage.updateData = kind.data?.data
                        storage.shouldUpdate = true
                        output.header?.update(.storage(storage))
                }

            case .normal:
                break
        }

    }

    private func deleteImage(imageType: ImageType) {
        switch imageType {
            case .icon:
                switch output.icon.content {
                    case .data, .none:
                        output.icon = .empty

                    case let .storage(storage):
                        output.icon = .content(.storage(
                            .init(
                                storageReference: storage.storageReference,
                                shouldUpdate: false,
                                updateData: nil
                            )
                        ))
                }
            case .header:
                switch output.header {
                    case .data:
                        output.header = nil

                    case .storage:
                        output.header?.toggleStorageUpdateFlag()

                    default:
                        break
                }
            case .normal:
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

    // この一連の流れUser、Rock、Courseで共通なので共通化したい。
    func uploadImage() {
        prepareUploadImage(imageType: .icon, imageDataKind: output.icon.content)
        prepareUploadImage(imageType: .header, imageDataKind: output.header)
        uploader.start()
    }

    private func prepareUploadImage(imageType: ImageType, imageDataKind: ImageDataKind?) {

        let headerReference = StorageManager.makeImageReferenceForUpload(
            destinationDocument: FINameSpace.Users.self,
            documentId: user.id,
            imageType: imageType
        )

        switch imageDataKind {
            case .data(let data):
                uploader.addData(
                    data: data.data,
                    reference: headerReference
                )

            case .storage(let storage):
                guard
                    storage.shouldUpdate
                else {
                    output.imageUploadState = .complete([])
                    return
                }

                guard
                    let updateData = storage.updateData
                else {
                    storage.storageReference.delete()
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: {}
                        )
                        .store(in: &bindings)

                    output.imageUploadState = .complete([])
                    return
                }

                storage.storageReference.delete()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: {}
                    )
                    .store(in: &bindings)

                uploader.addData(
                    data: updateData,
                    reference: headerReference
                )
            case .none:
                output.imageUploadState = .complete([])
                return
        }
    }

    func fetchImageUrl() {
        let header = StorageManager
            .getReference(
                destinationDocument: FINameSpace.Users.self,
                documentId: user.id,
                imageType: .header
            )
            .compactMap { $0 }
            .flatMap { $0.getDownloadURL() }

        let icon = StorageManager
            .getReference(
                destinationDocument: FINameSpace.Users.self,
                documentId: user.id,
                imageType: .icon
            )
            .compactMap { $0 }
            .flatMap { $0.getDownloadURL() }

        header.zip(icon)
            .eraseToAnyPublisher()
            .sink(
                receiveCompletion: { [weak self] result in

                    guard let self = self else { return }

                    if case let .failure(error) = result {
                        self.output.imageUrlDownloadState = .failure(error)
                    }
                },
                receiveValue: { [weak self] headerUrl, iconUrl in

                    guard let self = self else { return }

                    self.output.imageUrlDownloadState = .finish(
                        content: (header: headerUrl, icon: iconUrl)
                    )
                }
            )
            .store(in: &bindings)
    }

    func editProfile() {

        output.userUploadState = .loading

        var updateUserDocument: FIDocument.User {
            var updateUser = user
            updateUser.name = output.name
            updateUser.introduction = output.introduction
            updateUser.socialLinks = output.socialLinks
            updateUser.headerUrl = output.imageUrlDownloadState.content?.header
            updateUser.photoURL = output.imageUrlDownloadState.content?.icon
            return updateUser
        }
        updateUserDocument.makeDocumentReference()
            .setData(from: updateUserDocument)
            .sinkState { [weak self] state in
                self?.output.userUploadState = state
            }
            .store(in: &bindings)
    }
}

extension EditProfileViewModel {

    struct Input {
        let nameSubject = PassthroughSubject<String?, Never>()
        let introductionSubject = PassthroughSubject<String?, Never>()
        let setImageSubject = PassthroughSubject<(ImageType, ImageDataKind), Never>()
        let deleteImageSubject = PassthroughSubject<ImageType, Never>()
        let socialLinkSubject = PassthroughSubject<FIDocument.User.SocialLink, Never>()
    }

    final class Output {
        @Published var name = ""
        @Published var introduction = ""
        @Published var header: ImageDataKind?
        @Published var icon: Emptiable<ImageDataKind> = .empty
        @Published var socialLinks: [FIDocument.User.SocialLink] = FIDocument.User.SocialLinkType.allCases.map {
            FIDocument.User.SocialLink(linkType: $0, link: "")
        }
        @Published var nameValidationResult: ValidationResult = .none

        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var imageUrlDownloadState: LoadingState<(header: URL?, icon: URL?)> = .stanby
        @Published var userUploadState: LoadingState<Void> = .stanby
    }
}

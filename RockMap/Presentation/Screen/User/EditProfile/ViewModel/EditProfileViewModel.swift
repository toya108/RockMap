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
    let user: Entity.User

    private var bindings           = Set<AnyCancellable>()
    private let updateUserUsecase  = Usecase.User.Update()
    private let fetchHeaderUsecase = Usecase.Image.Fetch.Header()
    private let fetchIconUsecase   = Usecase.Image.Fetch.Icon()
    private let writeImageUsecase  = Usecase.Image.Write()

    init(user: Entity.User) {
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
                        where: { $0.linkType.rawValue == socialLink.linkType.rawValue }
                    )
                else {
                    return
                }

                self.output.socialLinks[index].link = socialLink.link
            }
            .store(in: &bindings)
    }

    private func bindOutput() {
        output.$name
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &output.$nameValidationResult)
    }

    private func fetchImageStorage() {
        fetchHeaderUsecase.fetch(id: user.id, destination: .user)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { .init(imageType: .header, image: $0) }
            .assign(to: &output.$header)

        fetchIconUsecase.fetch(id: user.id, destination: .user)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { .init(imageType: .icon, image: $0) }
            .assign(to: &output.$icon)
    }

    private func setImage(imageType: ImageType, data: Data) {
        switch imageType {
            case .icon:
                output.icon.updateData = data

            case .header:
                output.header.updateData = data
                output.header.shouldDelete = false

            case .normal:
                break
        }
    }

    private func deleteImage(imageType: ImageType) {
        switch imageType {
            case .icon:
                output.icon.updateData = nil

            case .header:
                output.header.updateData = nil

                if output.header.image.url != nil {
                    output.header.shouldDelete = true
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

    func uploadImage() {

        self.output.imageUploadState = .loading

        let writeHeader = writeImageUsecase.write(
            data: output.header.updateData,
            shouldDelete: output.header.shouldDelete,
            image: output.header.image
        ) {
            .user
            user.id
            output.header.imageType
        }

        let writeIcon = writeImageUsecase.write(
            data: output.icon.updateData,
            shouldDelete: output.icon.shouldDelete,
            image: output.icon.image
        ) {
            .user
            user.id
            output.icon.imageType
        }

        writeHeader.combineLatest(writeIcon)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty()}

                print(error)
                self.output.imageUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in

                    guard let self = self else { return }

                    self.output.imageUploadState = .finish(content: ())
                }
            }
            .store(in: &bindings)
    }

    func editProfile() {

        output.userUploadState = .loading

        var updateUser: Entity.User {
            var updateUser = user
            updateUser.name = output.name
            updateUser.introduction = output.introduction
            updateUser.socialLinks = output.socialLinks
            return updateUser
        }

        updateUserUsecase.update(user: updateUser)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty()}

                print(error)
                self.output.userUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.userUploadState = .finish(content: ())
            }
            .store(in: &bindings)
    }
}

extension EditProfileViewModel {

    struct Input {
        let nameSubject = PassthroughSubject<String?, Never>()
        let introductionSubject = PassthroughSubject<String?, Never>()
        let setImageSubject = PassthroughSubject<(ImageType, Data), Never>()
        let deleteImageSubject = PassthroughSubject<ImageType, Never>()
        let socialLinkSubject = PassthroughSubject<Entity.User.SocialLink, Never>()
    }

    final class Output {
        @Published var name = ""
        @Published var introduction = ""
        @Published var header: CrudableImageV2 = .init(imageType: .header)
        @Published var icon: CrudableImageV2 = .init(imageType: .icon)
        @Published var socialLinks: [Entity.User.SocialLink] = Entity.User.SocialLinkType.allCases.map {
            Entity.User.SocialLink(linkType: $0, link: "")
        }
        @Published var nameValidationResult: ValidationResult = .none

        @Published var imageUploadState: LoadingState<Void> = .stanby
        @Published var userUploadState: LoadingState<Void> = .stanby
    }
}

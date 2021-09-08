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

    private var bindings = Set<AnyCancellable>()
    private let updateUserUsecase = Usecase.User.Update()
    private let fetchHeaderUsecase = Usecase.Image.Fetch.Header()
    private let fetchIconUsecase = Usecase.Image.Fetch.Icon()
    private let writeImageUsecase = Usecase.Image.Write()

    init(user: Entity.User) {
        self.user = user
        self.bindInput()
        self.bindOutput()

        self.input.nameSubject.send(user.name)
        self.input.introductionSubject.send(user.introduction)
        self.fetchImageStorage()
        user.socialLinks.forEach {
            input.socialLinkSubject.send($0)
        }
    }

    private func bindInput() {
        self.input.nameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &self.output.$name)

        self.input.introductionSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &self.output.$introduction)

        self.input.setImageSubject
            .sink(receiveValue: self.setImage)
            .store(in: &self.bindings)

        self.input.deleteImageSubject
            .sink(receiveValue: self.deleteImage)
            .store(in: &self.bindings)

        self.input.socialLinkSubject
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
            .store(in: &self.bindings)
    }

    private func bindOutput() {
        self.output.$name
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &self.output.$nameValidationResult)
    }

    private func fetchImageStorage() {
        self.fetchHeaderUsecase.fetch(id: self.user.id, destination: .user)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { .init(imageType: .header, image: $0) }
            .assign(to: &self.output.$header)

        self.fetchIconUsecase.fetch(id: self.user.id, destination: .user)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { .init(imageType: .icon, image: $0) }
            .assign(to: &self.output.$icon)
    }

    private func setImage(imageType: Entity.Image.ImageType, data: Data) {
        switch imageType {
        case .icon:
            self.output.icon.updateData = data

        case .header:
            self.output.header.updateData = data
            self.output.header.shouldDelete = false

        case .normal, .unhandle:
            break
        }
    }

    private func deleteImage(imageType: Entity.Image.ImageType) {
        switch imageType {
        case .icon:
            self.output.icon.updateData = nil

        case .header:
            self.output.header.updateData = nil

            if self.output.header.image.url != nil {
                self.output.header.shouldDelete = true
            }

        case .normal, .unhandle:
            break
        }
    }

    func callValidations() -> Bool {
        if !self.output.nameValidationResult.isValid {
            self.output.nameValidationResult = UserNameValidator().validate(self.output.name)
        }
        return [
            self.output.nameValidationResult,
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }

    func uploadImage() {
        self.output.imageUploadState = .loading

        let writeHeader = self.writeImageUsecase.write(
            data: self.output.header.updateData,
            shouldDelete: self.output.header.shouldDelete,
            image: self.output.header.image
        ) {
            .user
            user.id
            output.header.imageType
        }

        let writeIcon = self.writeImageUsecase.write(
            data: self.output.icon.updateData,
            shouldDelete: self.output.icon.shouldDelete,
            image: self.output.icon.image
        ) {
            .user
            user.id
            output.icon.imageType
        }

        writeHeader.combineLatest(writeIcon)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

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
            .store(in: &self.bindings)
    }

    func editProfile() {
        self.output.userUploadState = .loading

        var updateUser: Entity.User {
            var updateUser = user
            updateUser.name = output.name
            updateUser.introduction = output.introduction
            updateUser.socialLinks = output.socialLinks
            return updateUser
        }

        self.updateUserUsecase.update(user: updateUser)
            .catch { [weak self] error -> Empty in

                guard let self = self else { return Empty() }

                print(error)
                self.output.userUploadState = .failure(error)
                return Empty()
            }
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.output.userUploadState = .finish(content: ())
            }
            .store(in: &self.bindings)
    }
}

extension EditProfileViewModel {
    struct Input {
        let nameSubject = PassthroughSubject<String?, Never>()
        let introductionSubject = PassthroughSubject<String?, Never>()
        let setImageSubject = PassthroughSubject<(Entity.Image.ImageType, Data), Never>()
        let deleteImageSubject = PassthroughSubject<Entity.Image.ImageType, Never>()
        let socialLinkSubject = PassthroughSubject<Entity.User.SocialLink, Never>()
    }

    final class Output {
        @Published var name = ""
        @Published var introduction = ""
        @Published var header: CrudableImage = .init(imageType: .header)
        @Published var icon: CrudableImage = .init(imageType: .icon)
        @Published var socialLinks: [Entity.User.SocialLink] = Entity.User.SocialLinkType.allCases
            .map {
                Entity.User.SocialLink(linkType: $0, link: "")
            }

        @Published var nameValidationResult: ValidationResult = .none

        @Published var imageUploadState: LoadingState<Void> = .stanby
        @Published var userUploadState: LoadingState<Void> = .stanby
    }
}

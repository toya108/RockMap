import Foundation
import Combine

class EditProfileViewModelV2: ObservableObject {

    @Published var iconURL: URL?
    @Published var iconData: Data?
    @Published var headerURL: URL?
    @Published var headerData: Data?
    @Published var name = ""
    @Published var introduction = ""
    @Published var facebook = ""
    @Published var twitter = ""
    @Published var instagram = ""
    @Published var other = ""

    @Published var isValidName = false
    @Published var isLoading = false
    @Published var isPresentedDismissConfirmation = false
    @Published var isPresentedIconPicker = false
    @Published var isPresentedHeaderPicker = false
    @Published var isPresentedPickerFailureAlert = false
    @Published var isPresentedUserUpdateAlert = false
    @Published var pickerState: LoadingState<PHPickerView.Return> = .standby
    @Published var userUpdateState: LoadingState<Void> = .standby

    private let user: Entity.User
    private let updateUserUsecase = Usecase.User.Update()
    private let setImageUsecase = Usecase.Image.Set()
    private let deleteImageUsecase = Usecase.Image.Delete()

    private var cancellables = Set<AnyCancellable>()

    init(user: Entity.User) {
        self.user = user
        self.setupInitialValues()
        self.setupBinding()
    }

    @MainActor func startUpdateSequences() {

        guard self.isValidName else {
            return
        }

        self.userUpdateState = .loading

        Task {
            do {
                try await self.updateUser()
                try await self.uploadImage()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.userUpdateState = .finish(content: ())
                }
            } catch {
                self.userUpdateState = .failure(error)
            }
        }
    }

    private func updateUser() async throws {
        var updatedUser: Entity.User {
            var new = self.user
            new.name = self.name
            new.introduction = self.introduction
            new.socialLinks = self.socialLinks
            return new
        }

        try await self.updateUserUsecase.update(user: updatedUser)
    }

    private func uploadImage() async throws {
        if let iconData = self.iconData {
            try? await self.deleteImageUsecase.delete(
                path: ["users", user.id, Entity.Image.ImageType.icon.name].joined(separator: "/"),
                isFile: false
            )
            try await self.setImageUsecase.set(
                path: makeStoragePath(imageType: .icon),
                data: iconData
            )
        }
        if let headerData = self.headerData {
            try? await self.deleteImageUsecase.delete(
                path: ["users", user.id, Entity.Image.ImageType.header.name].joined(separator: "/"),
                isFile: false
            )
            try await self.setImageUsecase.set(
                path: makeStoragePath(imageType: .header),
                data: headerData
            )
        }
    }

    private func makeStoragePath(imageType: Entity.Image.ImageType) -> String {
        ["users", user.id, imageType.name, UUID().uuidString].joined(separator: "/")
    }

    private func setupBinding() {
        $pickerState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in

                guard let self = self else { return }

                switch state {
                    case.failure:
                        self.isPresentedPickerFailureAlert = true

                    case .finish(let content):
                        switch content.imageType {
                            case .header:
                                self.headerData = content.data

                            case .icon:
                                self.iconData = content.data

                            default:
                                break
                        }
                    default:
                        break
                }
            }
            .store(in: &cancellables)

        $name
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in

                guard let self = self else { return }

                self.isValidName = UserNameValidator().validate(self.name).isValid
            }
            .store(in: &cancellables)
    }

    private func setupInitialValues() {
        self.headerURL = user.headerUrl
        self.iconURL = user.photoURL
        self.name = user.name
        if let introduction = user.introduction {
            self.introduction = introduction
        }
        if let facebookLink = user.socialLinks.first(where: { $0.linkType == .facebook  })?.link {
            self.facebook = facebookLink
        }
        if let twitterLink = user.socialLinks.first(where: { $0.linkType == .twitter  })?.link {
            self.twitter = twitterLink
        }
        if let instagramLink = user.socialLinks.first(where: { $0.linkType == .instagram  })?.link {
            self.instagram = instagramLink
        }
        if let otherLink = user.socialLinks.first(where: { $0.linkType == .other  })?.link {
            self.other = otherLink
        }
    }

    private var socialLinks: [Entity.User.SocialLink] {
        [
            .init(linkType: .facebook, link: self.facebook),
            .init(linkType: .twitter, link: self.twitter),
            .init(linkType: .instagram, link: self.instagram),
            .init(linkType: .other, link: self.other)
        ]
    }
}

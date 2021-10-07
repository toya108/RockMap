import Auth
import Combine

final class LoginViewModel: ObservableObject {

    @Published var shouldChangeRootToMain = false
    @Published var isPresentedAuthView = false
    @Published var isPresentedAuthFailureAlert = false
    @Published var isPresentedLogoutAlert = false
    @Published var isPresentedDidLogoutAlert = false
    @Published var isPresentedLogoutFailureAlert = false
    @Published var isPresentedTerms = false
    @Published var isPresentedPrivacyPolicy = false

    var appStore: AppStore?
    var authError: Error?
    var logoutError: Error?
    private let authAccessor: AuthAccessorProtocol
    let authCoordinator: AuthCoordinatorProtocol
    private var loginFinishedCancellable: Cancellable?

    init(
        authAccessor: AuthAccessorProtocol = AuthAccessor(),
        authCoordinator: AuthCoordinatorProtocol = AuthCoordinator()
    ) {
        self.authAccessor = authAccessor
        self.authCoordinator = authCoordinator
        setupBindings()
    }

    func loginIfNeeded() {
        if authAccessor.isLoggedIn {
            self.appStore?.rootViewType = .main
        } else {
            self.isPresentedAuthView = true
        }
    }

    func guestLoginIfNeeded() {
        if authAccessor.isLoggedIn {
            self.isPresentedLogoutAlert = true
        } else {
            self.appStore?.rootViewType = .main
        }
    }

    func logout() {
        do {
            try authAccessor.logout()
            self.isPresentedDidLogoutAlert = true
        } catch {
            self.logoutError = error
            self.isPresentedLogoutFailureAlert = true
        }
    }

    private func setupBindings() {
        self.loginFinishedCancellable = authCoordinator.loginFinishedPublisher
            .sink { [weak self] result in

                guard let self = self else { return }

                switch result {
                    case .success:
                        self.appStore?.rootViewType = .main

                    case let .failure(error):
                        self.authError = error
                        self.isPresentedAuthFailureAlert = true
                }
            }
    }
}


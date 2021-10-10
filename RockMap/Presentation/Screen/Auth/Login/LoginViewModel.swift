import Auth
import Combine
import Resolver

final class LoginViewModel: ObservableObject {

    @Published var shouldChangeRootToMain = false
    @Published var isPresentedAuthView = false
    @Published var isPresentedAuthFailureAlert = false
    @Published var isPresentedLogoutAlert = false
    @Published var isPresentedDidLogoutAlert = false
    @Published var isPresentedLogoutFailureAlert = false
    @Published var isPresentedTerms = false
    @Published var isPresentedPrivacyPolicy = false
    @Published var shouldChangeRootView = false

    var authError: Error?
    var logoutError: Error?

    @Injected var authAccessor: AuthAccessorProtocol
    @Injected var authCoordinator: AuthCoordinatorProtocol
    private var loginFinishedCancellable: Cancellable?

    init() {
        setupBindings()
    }

    func loginIfNeeded() {
        if authAccessor.isLoggedIn {
            self.shouldChangeRootView = true
        } else {
            self.isPresentedAuthView = true
        }
    }

    func guestLoginIfNeeded() {
        if authAccessor.isLoggedIn {
            self.isPresentedLogoutAlert = true
        } else {
            self.shouldChangeRootView = true
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
                        self.shouldChangeRootView = true

                    case let .failure(error):
                        self.authError = error
                        self.isPresentedAuthFailureAlert = true
                }
            }
    }
}


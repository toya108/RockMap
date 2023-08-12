import Resolver
import Combine

class AccountViewModel: ObservableObject {

    @Published var shouldChangeRootToLogin = false
    @Published var isPresentedLogoutAlert = false
    @Published var isPresentedLogoutFailureAlert = false
    @Published var isPresentedDeleteAccountAlert = false
    @Published var isPresentedDeleteAccountFailureAlert = false

    var deleteAccountError: Error?
    var logoutError: Error?

    @Injected var authAccessor: AuthAccessorProtocol
    @Injected var authCoordinator: AuthCoordinatorProtocol
    @Injected private var deleteUserUsecase: DeleteUserUsecaseProtocol

    func logout() {
        do {
            try authAccessor.logout()
            shouldChangeRootToLogin = true
        } catch {
            self.logoutError = error
            self.isPresentedLogoutFailureAlert = true
        }
    }

    @MainActor func deleteAccount() {
        Task {
            do {
                try await self.deleteUserUsecase.delete(id: authAccessor.uid)
                try authAccessor.logout()

                shouldChangeRootToLogin = true
            } catch {
                deleteAccountError = error
                isPresentedDeleteAccountFailureAlert = true
            }
        }
    }
    
}


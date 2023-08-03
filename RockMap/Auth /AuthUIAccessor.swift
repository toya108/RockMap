import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FirebaseAuthUI

public struct AuthUIAccessor {

    public init() {}

    private let authUI: FUIAuth? = {
        guard
            let authUI = FUIAuth.defaultAuthUI()
        else {
            return nil
        }
        authUI.providers = [
            FUIGoogleAuth(authUI: authUI),
            FUIEmailAuth(),
            FUIOAuth.appleAuthProvider()
        ]
        return authUI
    }()

    public func authViewController(
        coordinator: AuthCoordinatorProtocol
    ) -> UIViewController? {

        guard let authUI = self.authUI else { return nil }

        authUI.delegate = coordinator
        return authUI.authViewController().viewControllers.first
    }
}

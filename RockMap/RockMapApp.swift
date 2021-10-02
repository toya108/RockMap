import Auth
import SwiftUI

@main
struct RockMapApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appStore = AppStore(
        rootViewType: AuthManager.shared.isLoggedIn ? .main : .login
    )

    var body: some Scene {
        WindowGroup {
            appStore.rootView
                .environmentObject(appStore)
        }
    }

}

final class AppStore: ObservableObject {

    enum RootViewType {
        case main
        case login
    }

    @Published var rootViewType: RootViewType = .login

    init(rootViewType: RootViewType) {
        self.rootViewType = rootViewType
    }

    @ViewBuilder
    var rootView: some View {
        switch rootViewType {
            case .main:
                MainTabView()

            case .login:
                LoginView()
        }
    }
}

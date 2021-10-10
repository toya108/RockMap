import Auth
import SwiftUI

@main
struct RockMapApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appStore = AppStore.shared

    var body: some Scene {
        WindowGroup {
            appStore.rootView
                .environmentObject(appStore)
        }
    }

}

final class AppStore: ObservableObject {

    static let shared: AppStore = AppStore()

    private init() {
        rootViewType = AuthAccessor().isLoggedIn ? .main : .login
    }

    enum RootViewType {
        case main
        case login
    }

    @Published var rootViewType: RootViewType = .login

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

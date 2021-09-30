import Auth
import SwiftUI

@main
struct RockMapApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if AuthManager.shared.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}


//
//  AppDelegate.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/03.
//

import UIKit
import Firebase
import FirebaseUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupFirebase()
        setupRemoteConfig()
        setupPermissionOfLocation()
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {

        guard
            let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        else {
            return false
        }
        
        // GoogleもしくはFacebook認証の場合、trueを返す
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return false
    }

    private func setupFirebase() {

        let configFileName: String
        #if DEBUG
        configFileName = "GoogleService-Info-dev"
        #else
        configFileName = "GoogleService-Info-release"
        #endif

        guard
            let filePath = Bundle.main.path(forResource: configFileName, ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath)
        else {
            fatalError("Firebase plist file is not found.")
        }

        FirebaseApp.configure(options: options)
    }

    private func setupRemoteConfig() {
        let remoteConfigListener = RemoteConfigListener()
        remoteConfigListener.fetchAndActivateRemoteConfig { result in

            guard case .success = result else {
                return
            }

            ForceUpdateAlertManager().showGoToStoreAlertIfNeeded(
                minimumAppVersion: remoteConfigListener.minimumAppVersion
            )
        }
    }

    private func setupPermissionOfLocation() {
        LocationManager.shared.requestWhenInUseAuthorization()
    }
}


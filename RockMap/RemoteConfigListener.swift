//
//  RemoteConfigListener.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/07/04.
//

import FirebaseRemoteConfig

struct RemoteConfigListener {

    let remoteConfig: RemoteConfig = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
        return remoteConfig
    }()

    var minimumAppVersion: String {
        remoteConfig.configValue(forKey: "minimum_app_version").stringValue ?? ""
    }

    func fetchAndActivateRemoteConfig(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        remoteConfig.fetchAndActivate { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }
    }

}

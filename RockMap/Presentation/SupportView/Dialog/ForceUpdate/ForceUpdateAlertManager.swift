import UIKit

struct ForceUpdateAlertManager {
    func showGoToStoreAlertIfNeeded(minimumAppVersion: String) {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

        guard
            self.isUpdateRequired(
                requiredVersion: minimumAppVersion,
                currentVersion: currentVersion
            )
        else {
            return
        }

        let forceUpdateAlert = UIAlertController(
            title: "最新バージョンがリリースされています。",
            message: "Appストアから最新バージョンへアプリをアップデートしてお使い下さい。",
            preferredStyle: .alert
        )
        let goToStoreAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { _ in
        }
        forceUpdateAlert.addAction(goToStoreAction)

        UIApplication.shared.windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .present(forceUpdateAlert, animated: true)
    }

    /**
     Compare which version is the latest in the following format.
     Format: `x.x.x`
     */
    func isUpdateRequired(
        requiredVersion: String,
        currentVersion: String
    ) -> Bool {
        var required = requiredVersion.components(separatedBy: ".").map { Int($0) ?? 0 }
        var current = currentVersion.components(separatedBy: ".").map { Int($0) ?? 0 }

        let diff = required.count - current.count
        let padding = Array(repeating: 0, count: abs(diff))
        if diff > 0 {
            current.append(contentsOf: padding)
        } else if diff < 0 {
            required.append(contentsOf: padding)
        }

        for (r, c) in zip(required, current) {
            if r > c {
                return true
            } else if r < c {
                return false
            }
        }

        return false
    }
}

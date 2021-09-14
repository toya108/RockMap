import Firebase
import FirebaseFirestore
import Foundation

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en-US")
    f.dateFormat = "yyyyMMddHHmmssSSS"
    return f
}()

enum FirebaseTestHelper {
    static func setupFirebaseApp() {
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(googleAppID: "1:123:ios:123abc", gcmSenderID: "sender_id")
            options.projectID = "test-" + dateFormatter.string(from: Date())
            options.storageBucket = "project-id-123.storage.firebase.com"
            FirebaseApp.configure(options: options)
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
            print("FirebaseApp has been configured")
        }
    }

    static func deleteFirebaseApp() {
        guard let app = FirebaseApp.app() else {
            return
        }
        app.delete { _ in print("FirebaseApp has been deleted") }
    }
}

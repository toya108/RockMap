import SwiftUI
import StoreKit

struct SettingsView: View {

    @State private var shouldShowPrivacyPolicy = false
    @State private var shouldShowTerm = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("account")) {
                    NavigationLink(
                        destination: {
                            AccountView()
                        },
                        label: {
                            HStack {
                                Image(uiImage: UIImage.SystemImages.personCircle)
                                Text("account")
                            }
                        }
                    )
                }
                Section(header: Text("about_this_app")) {
                    HStack {
                        Image(uiImage: UIImage.SystemImages.checkmarkShield)
                        Text("privacy_policy").onTapGesture {
                            shouldShowPrivacyPolicy.toggle()
                        }
                    }
                    HStack {
                        Image(uiImage: UIImage.SystemImages.docPlaintext)
                        Text("terms").onTapGesture {
                            shouldShowPrivacyPolicy.toggle()
                        }
                    }
                    HStack {
                        Image(uiImage: UIImage.SystemImages.starCircle)
                        Text("review").onTapGesture {
                            guard
                                let scene = UIApplication.shared.connectedScenes.first(
                                    where: { $0.activationState == .foregroundActive }
                                ) as? UIWindowScene
                            else {
                                return
                            }
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("settings")
        }
        .sheet(isPresented: $shouldShowPrivacyPolicy) {
            SafariView(url: Resources.Const.Url.privacyPolicy)
        }
        .sheet(isPresented: $shouldShowTerm) {
            SafariView(url: Resources.Const.Url.terms)
        }

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

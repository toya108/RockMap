import SwiftUI
import StoreKit

struct SettingsView: View {

    @State private var shouldShowPrivacyPolicy = false
    @State private var shouldShowTerm = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("アカウント")) {
                    NavigationLink(
                        destination: {
                            AccountView()
                        },
                        label: {
                            HStack {
                                Image(uiImage: UIImage.SystemImages.personCircle)
                                Text("アカウント")
                            }
                        }
                    )
                }
                Section(header: Text("このアプリについて")) {
                    HStack {
                        Image(uiImage: UIImage.SystemImages.checkmarkShield)
                        Text("プライバシーポリシー").onTapGesture {
                            shouldShowPrivacyPolicy.toggle()
                        }
                    }
                    HStack {
                        Image(uiImage: UIImage.SystemImages.docPlaintext)
                        Text("利用規約").onTapGesture {
                            shouldShowPrivacyPolicy.toggle()
                        }
                    }
                    HStack {
                        Image(uiImage: UIImage.SystemImages.starCircle)
                        Text("レビュー").onTapGesture {
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
            .navigationTitle("設定")
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

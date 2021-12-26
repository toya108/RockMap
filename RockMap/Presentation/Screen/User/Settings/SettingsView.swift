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
                        destination: AccountView(),
                        label: {
                            HStack {
                                Image(uiImage: UIImage.SystemImages.personCircle)
                                    .renderingMode(.template)
                                    .foregroundColor(Color(uiColor: .label))
                                Text("account")
                            }
                        }
                    )
                }
                Section(header: Text("about_this_app")) {
                    EntireTappableRowView {
                        Image(uiImage: UIImage.SystemImages.checkmarkShield)
                            .renderingMode(.template)
                            .foregroundColor(Color(uiColor: .label))
                        Text("privacy_policy")
                    }
                    .onTapGesture {
                        shouldShowPrivacyPolicy.toggle()
                    }
                    EntireTappableRowView {
                        Image(uiImage: UIImage.SystemImages.docPlaintext)
                            .renderingMode(.template)
                            .foregroundColor(Color(uiColor: .label))
                        Text("terms")
                    }
                    .onTapGesture {
                        shouldShowPrivacyPolicy.toggle()
                    }
                    EntireTappableRowView {
                        Image(uiImage: UIImage.SystemImages.starCircle)
                            .renderingMode(.template)
                            .foregroundColor(Color(uiColor: .label))
                        Text("review")
                    }
                    .onTapGesture {
                        showStoreReview()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $shouldShowPrivacyPolicy) {
            SafariView(url: Resources.Const.Url.privacyPolicy)
        }
        .sheet(isPresented: $shouldShowTerm) {
            SafariView(url: Resources.Const.Url.terms)
        }
    }

    private func showStoreReview() {
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

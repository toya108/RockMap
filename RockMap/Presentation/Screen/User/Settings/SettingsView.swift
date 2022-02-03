import SwiftUI
import StoreKit

struct SettingsView: View {

    @State private var shouldShowPrivacyPolicy = false
    @State private var shouldShowTerm = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("account")) {
                    NavigationLink(
                        destination: AccountView {
                            dismiss()
                        },
                        label: {
                            HStack {
                                Image(uiImage: Resources.Images.System.personCircle.uiImage)
                                    .renderingMode(.template)
                                    .foregroundColor(Color(uiColor: .label))
                                Text("account")
                            }
                        }
                    )
                }
                Section(header: Text("about_this_app")) {
                    EntireTappableRowView {
                        Image(uiImage: Resources.Images.System.checkmarkShield.uiImage)
                            .renderingMode(.template)
                            .foregroundColor(Color(uiColor: .label))
                        Text("privacy_policy")
                    }
                    .onTapGesture {
                        shouldShowPrivacyPolicy.toggle()
                    }
                    EntireTappableRowView {
                        Image(uiImage: Resources.Images.System.docPlaintext.uiImage)
                            .renderingMode(.template)
                            .foregroundColor(Color(uiColor: .label))
                        Text("terms")
                    }
                    .onTapGesture {
                        shouldShowPrivacyPolicy.toggle()
                    }
                    EntireTappableRowView {
                        Image(uiImage: Resources.Images.System.starCircle.uiImage)
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

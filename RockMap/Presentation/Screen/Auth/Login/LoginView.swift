import Auth
import SwiftUI

struct LoginView: View {

    @ObservedObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appStore: AppStore

    var body: some View {
        VStack(spacing: 24) {
            Image(uiImage: UIImage.AssetsImages.mountainBackGround)
                .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 16) {
                Text("RockMap")
                    .font(.system(size: 33, weight: .heavy))
                Text("text_hello")
                    .font(.system(size: 18, weight: .heavy))
                Text("text_rockmap_description")
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            VStack {
                HStack {
                    Button(
                        action: {
                            viewModel.loginIfNeeded()
                        },
                        label: {
                            Text("login")
                                .font(.system(size: 20, weight: .heavy, design: .default))
                                .padding(8)
                                .foregroundColor(Color(uiColor: .white))
                                .background(Color(uiColor: UIColor.Pallete.primaryGreen))
                        }
                    )
                    .cornerRadius(8)
                    .fullScreenCover(isPresented: $viewModel.isPresentedAuthView) {
                        AuthView()
                    }
                    Button(
                        action: {
                            viewModel.guestLoginIfNeeded()
                        },
                        label: {
                            Text("guest_login")
                                .font(.system(size: 20, weight: .heavy, design: .default))
                                .padding(8)
                                .foregroundColor(Color(uiColor: UIColor.Pallete.primaryGreen))
                        }
                    )
                    .cornerRadius(8)
                    Spacer()
                }
                HStack {
                    Button("terms") {
                        viewModel.isPresentedTerms.toggle()
                    }
                    .font(.system(size: 14))
                    .sheet(isPresented: $viewModel.isPresentedTerms) {
                        SafariView(url: Resources.Const.Url.terms)
                    }
                    Button("privacy_policy") {
                        viewModel.isPresentedPrivacyPolicy.toggle()
                    }
                    .font(.system(size: 14))
                    .sheet(isPresented: $viewModel.isPresentedPrivacyPolicy) {
                        SafariView(url: Resources.Const.Url.privacyPolicy)
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.appStore = appStore
        }
        .alert(
            "text_auth_failure",
            isPresented: $viewModel.isPresentedAuthFailureAlert,
            actions: {
                Button("ok") {}
            },
            message: {
                Text(viewModel.authError?.localizedDescription ?? "")
            }
        )
        .alert("text_logout_succeeded", isPresented: $viewModel.isPresentedDidLogoutAlert) {
            Button("ok") {}
        }
        .alert(
            "text_logout_failure",
            isPresented: $viewModel.isPresentedLogoutFailureAlert,
            actions: {
                Button("ok") {}
            },
            message: {
                Text("retry_suggestion_with\(viewModel.logoutError?.localizedDescription ?? "")")
            }
        )
        .alert(
            "text_logout_question",
            isPresented: $viewModel.isPresentedLogoutAlert,
            actions: {
                Button("yes") {
                    viewModel.logout()
                }
                Button("cancel") {
                    viewModel.isPresentedLogoutAlert = false
                }
            },
            message: {
                Text("text_aleady_logged_in_with\(AuthManager.shared.displayName)")
            }
        )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
        }
    }
}

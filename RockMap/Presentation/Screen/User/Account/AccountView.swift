import SwiftUI
import Resolver

struct AccountView: View {

    @StateObject var viewModel: AccountViewModel = Resolver.resolve()
    let dismissParent: () -> Void

    init(dismissParent: @escaping () -> Void) {
        self.dismissParent = dismissParent
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("user_information")) {
                    HStack {
                        Text("id")
                        Spacer()
                        Text(viewModel.authAccessor.uid)
                    }
                    HStack {
                        Text("how_to_login")
                        Spacer()
                        Text(viewModel.authAccessor.providerID)
                    }
                }
                Section(header: Text("manage_account")) {
                    EntireTappableRowView {
                        Text(viewModel.authAccessor.isLoggedIn ? "logout" : "login")
                    }
                    .onTapGesture {
                        if viewModel.authAccessor.isLoggedIn {
                            viewModel.isPresentedLogoutAlert = true
                        } else {
                            AppStore.shared.rootViewType = .login
                            dismissParent()
                        }
                    }

                    if viewModel.authAccessor.isLoggedIn {
                        EntireTappableRowView {
                            Text("delete_account")
                        }
                        .onTapGesture {
                            viewModel.isPresentedDeleteAccountAlert = true
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("account")
            .onReceive(viewModel.$shouldChangeRootToLogin) {
                guard $0 else {
                    return
                }

                AppStore.shared.rootViewType = .login
                dismissParent()
            }
            .alert(
                "would_you_like_to_delete_your_account",
                isPresented: $viewModel.isPresentedDeleteAccountAlert,
                actions: {
                    Button("ok", role: .destructive) {
                        viewModel.deleteAccount()
                    }
                    Button("cancel", role: .cancel) {
                        viewModel.isPresentedDeleteAccountAlert = false
                    }
                },
                message: {
                    Text("delete_account_alert_message")
                }
            )
            .alert(
                "account_deleting_failed",
                isPresented: $viewModel.isPresentedDeleteAccountFailureAlert,
                actions: {
                    Button("ok") {}
                },
                message: {
                    Text(viewModel.deleteAccountError?.localizedDescription ?? "")
                }
            )
            .alert(
                "text_logout_question",
                isPresented: $viewModel.isPresentedLogoutAlert,
                actions: {
                    Button("yes") {
                        viewModel.logout()
                    }
                    Button("cancel", role: .cancel) {
                        viewModel.isPresentedLogoutAlert = false
                    }
                },
                message: {
                    Text("logout_alert_message")
                }
            )
            .alert(
                "text_logout_failure",
                isPresented: $viewModel.isPresentedLogoutFailureAlert,
                actions: {
                    Button("ok") {}
                },
                message: {
                    Text(viewModel.logoutError?.localizedDescription ?? "")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView {}
    }
}

import SwiftUI

struct UserListView: View {

    @StateObject var viewModel: UserListViewModel

    var body: some View {
        switch viewModel.viewState {
            case .standby:
                Color.clear.onAppear {
                    Task {
                        await viewModel.load()
                    }
                }

            case .loading:
                ListSkeltonView()

            case .failure:
                EmptyView(text: .init("text_fetch_user_failed"))

            case .finish:
                if viewModel.users.isEmpty {
                    EmptyView(text: .init("text_no_user"))

                } else {
                    List(viewModel.users) { user in
                        UserRowView(user: user)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        Task {
                            await viewModel.load()
                        }
                    }
                }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(viewModel: .init())
    }
}

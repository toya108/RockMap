import SwiftUI

struct UserSearchView: View {

    @StateObject var viewModel: UserSearchViewModel
    @ObservedObject var searchRootViewModel: SearchRootViewModel

    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    search()
                }
                .onChange(of: searchRootViewModel.searchCondition) { _ in
                    search()
                }
            switch viewModel.viewState {
                case .standby:
                    Color.clear

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
                            search()
                        }
                    }
            }
        }
    }

    private func search() {
        Task {
            await viewModel.search(
                condition: searchRootViewModel.searchCondition,
                isAdditional: false
            )
        }
    }
}

struct UserSearchView_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchView(viewModel: .init(), searchRootViewModel: .init())
    }
}

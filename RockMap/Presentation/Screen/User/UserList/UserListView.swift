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
                        NavigationLink(
                            destination: MyPageView(userKind: .other(user: user))
                        ) {
                            HStack {
                                AsyncImage(
                                    url: user.photoURL,
                                    content: { image in
                                        image.resizable().scaledToFill()
                                    },
                                    placeholder: {
                                        ProgressView()
                                    }
                                )
                                .clipShape(Circle())
                                .frame(width: 44, height: 44)
                                Text(user.name)
                            }
                            .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        Task {
                            await viewModel.refresh()
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

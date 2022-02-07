import SwiftUI

struct RockSearchView: View {

    @StateObject var viewModel: RockSearchViewModel
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
                    EmptyView(text: .init("text_fetch_rock_failed"))

                case .finish:
                    if viewModel.rocks.isEmpty {
                        EmptyView(text: .init("text_no_rock"))

                    } else {
                        List(viewModel.rocks) { rock in
                            NavigationLink(
                                destination: RockDetailView(rock: rock)
                            ) {
                                ListRowView(rock: rock)
                                    .onAppear {
                                        additionalLoadIfNeeded(rock: rock)
                                    }
                            }
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

    private func additionalLoadIfNeeded(rock: Entity.Rock) {
        Task {
            guard await viewModel.shouldAdditionalLoad(rock: rock) else {
                return
            }
            await viewModel.additionalLoad(condition: searchRootViewModel.searchCondition)
        }
    }

}

struct RockSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RockSearchView(viewModel: .init(), searchRootViewModel: .init())
    }
}

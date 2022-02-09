import SwiftUI

struct RockListView: View {

    @StateObject var viewModel: RockListViewModel
    @ObservedObject var searchRootViewModel: SearchRootViewModel

    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    load()
                }
                .onChange(of: searchRootViewModel.searchCondition) { _ in
                    load()
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
                            load()
                        }
                    }
            }
        }
    }

    private func load() {
        Task {
            await viewModel.load(condition: searchRootViewModel.searchCondition)
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

struct RockListView_Previews: PreviewProvider {
    static var previews: some View {
        RockListView(viewModel: .init(), searchRootViewModel: .init())
    }
}

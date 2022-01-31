import SwiftUI

struct RockSearchView: View {

    @StateObject var viewModel: RockSearchViewModel
    @ObservedObject var searchCondition: SearchCondition

    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    search()
                }
                .onChange(of: searchCondition.searchText) { _ in
                    search()
                }
            switch viewModel.viewState {
                case .standby:
                    Color.clear

                case .loading:
                    ListSkeltonView()

                case .failure:
                    EmptyView(text: .init("text_fetch_rock_failed"))
                        .refreshable {
                            refresh()
                        }

                case .finish:
                    if viewModel.rocks.isEmpty {
                        EmptyView(text: .init("text_no_rock"))
                            .refreshable {
                                refresh()
                            }

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
                            refresh()
                        }
                    }
            }
        }
    }

    private func search() {
        Task {
            await viewModel.search(condition: searchCondition, isAdditional: false)
        }
    }

    private func additionalLoadIfNeeded(rock: Entity.Rock) {
        Task {
            guard await viewModel.shouldAdditionalLoad(rock: rock) else {
                return
            }
            await viewModel.additionalLoad(condition: searchCondition)
        }
    }

    private func refresh() {
        Task {
            await viewModel.refresh(condition: searchCondition)
        }
    }

}

struct RockSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RockSearchView(viewModel: .init(), searchCondition: .init())
    }
}

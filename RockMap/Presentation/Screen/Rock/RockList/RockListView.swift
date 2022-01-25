import SwiftUI

struct RockListView: View {

    @StateObject var viewModel: RockListViewModel

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
                            ListRowView(
                                imageURL: rock.headerUrl,
                                iconImage: UIImage.AssetsImages.rockFill,
                                title: rock.name,
                                firstLabel: .init("registered_date"),
                                firstText: rock.createdAt.string(dateStyle: .medium),
                                secondLabel: .init("address"),
                                secondText: rock.address,
                                thirdText: rock.desc
                            )
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

    private func load() {
        Task {
            await viewModel.load()
        }
    }

    private func additionalLoadIfNeeded(rock: Entity.Rock) {
        Task {
            guard await viewModel.shouldAdditionalLoad(rock: rock) else {
                return
            }
            await viewModel.load()
        }
    }

    private func refresh() {
        Task {
            await viewModel.refresh()
        }
    }

}

struct RockListView_Previews: PreviewProvider {
    static var previews: some View {
        RockListView(viewModel: .init())
    }
}

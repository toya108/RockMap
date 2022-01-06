import SwiftUI

struct RockListView: View {

    @StateObject var viewModel: RockListViewModelV2

    var body: some View {
        List {
            ForEach(viewModel.rocks) { rock in
                NavigationLink(
                    destination: RockDetailView(rock: rock),
                    label: {
                        ListRowView(
                            imageURL: rock.headerUrl,
                            iconImage: UIImage.AssetsImages.rockFill,
                            title: rock.name,
                            firstLabel: "登録日",
                            firstText: rock.createdAt.string(dateStyle: .medium),
                            secondLabel: "住所",
                            secondText: rock.address,
                            thirdText: rock.desc
                        )
                    }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("削除", role: .destructive) {
                        viewModel.delete(rock: rock)
                    }
                    Button("編集") {
                        if let index = viewModel.rocks.firstIndex(of: rock) {
                            viewModel.editingRockIndex = index
                        }
                        viewModel.shouldShowRockRegister = true
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchRockList()
        }
        .sheet(isPresented: $viewModel.shouldShowRockRegister) {
            RockRegisterView(registerType: .edit(viewModel.rocks[viewModel.editingRockIndex]))
                .interactiveDismissDisabled(true)
        }
    }
}

struct RockListView_Previews: PreviewProvider {
    static var previews: some View {
        RockListView(viewModel: .init(userId: "aaa"))
    }
}

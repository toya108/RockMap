import SwiftUI

struct RockListView: View {

    @StateObject var viewModel: RockListViewModelV2

    var body: some View {
        List(viewModel.rocks) { rock in
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
                    viewModel.editingRock = rock
                    viewModel.isPresentedDeleteRockAlert = true
                }
                Button("編集") {
                    viewModel.editingRock = rock
                    viewModel.isPresentedRockRegister = true
                }
            }
        }
        .onAppear {
            viewModel.fetchRockList()
        }
        .alert(
            "岩を削除しますか？",
            isPresented: $viewModel.isPresentedDeleteRockAlert,
            actions: {
                Button("削除", role: .destructive) {
                    viewModel.delete()
                }
                Button("cancel", role: .cancel) {
                    viewModel.isPresentedDeleteRockAlert = false
                }
            },
            message: {
                Text("一度削除すると復元できません。")
            }
        )
        .alert(
            "削除に失敗しました",
            isPresented: $viewModel.isPresentedDeleteFailureAlert,
            actions: {
                Button("yes") {}
            },
            message: {
                Text(viewModel.deleteError?.localizedDescription ?? "")
            }
        )
        .sheet(isPresented: $viewModel.isPresentedRockRegister) {
            if let rock = viewModel.editingRock {
                RockRegisterView(registerType: .edit(rock)).interactiveDismissDisabled(true)
            }
        }
    }
}

struct RockListView_Previews: PreviewProvider {
    static var previews: some View {
        RockListView(viewModel: .init(userId: "aaa"))
    }
}

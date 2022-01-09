import SwiftUI
import SkeletonUI

struct RockListView: View {

    @StateObject var viewModel: RockListViewModel

    var body: some View {
        if viewModel.rocks.isEmpty {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("まだ登録した岩はありません。")
            }
            .onAppear {
                viewModel.fetchRockList()
            }
        } else if viewModel.isLoading {
            Color.clear.skeleton(with: true)
                .shape(type: .rectangle)
                .multiline(lines: 8, spacing: 4)
                .padding()
        } else {
            List(viewModel.rocks) { rock in
                NavigationLink(
                    destination: RockDetailView(rock: rock)
                ) {
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
            .onReceive(
                NotificationCenter.default.publisher(for: .didRockRegisterFinished)
            ) { _ in
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
}

struct RockListView_Previews: PreviewProvider {
    static var previews: some View {
        RockListView(viewModel: .init(userId: "aaa"))
    }
}

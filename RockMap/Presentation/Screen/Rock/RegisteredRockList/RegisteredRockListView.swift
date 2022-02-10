import SwiftUI
import SkeletonUI

struct RegisteredRockListView: View {

    @StateObject var viewModel: RegisteredRockListViewModel

    var body: some View {
        if viewModel.rocks.isEmpty {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("text_no_rock_registerd_yet")
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
                    ListRowView(rock: rock)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("delete", role: .destructive) {
                        viewModel.editingRock = rock
                        viewModel.isPresentedDeleteRockAlert = true
                    }
                    Button("edit") {
                        viewModel.editingRock = rock
                        viewModel.isPresentedRockRegister = true
                    }
                }
            }
            .refreshable {
                viewModel.fetchRockList()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .didRockRegisterFinished)
            ) { _ in
                viewModel.fetchRockList()
            }
            .alert(
                "text_delete_rock_title",
                isPresented: $viewModel.isPresentedDeleteRockAlert,
                actions: {
                    Button("delete", role: .destructive) {
                        viewModel.delete()
                    }
                    Button("cancel", role: .cancel) {
                        viewModel.isPresentedDeleteRockAlert = false
                    }
                },
                message: {
                    Text("text_delete_rock_message")
                }
            )
            .alert(
                "text_delete_failure_title",
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

struct RegisteredRockListView_Previews: PreviewProvider {
    static var previews: some View {
        RegisteredRockListView(viewModel: .init(userId: "aaa"))
    }
}

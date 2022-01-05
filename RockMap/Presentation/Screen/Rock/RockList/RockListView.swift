import SwiftUI

struct RockListView: View {

    @StateObject var viewModel: RockListViewModelV2
    @Environment(\.editMode) var editMode

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
            }
            .onDelete {
                viewModel.delete(indexSet: $0)
            }
            .swipeActions {
                
            }
        }
        .onAppear {
            viewModel.fetchRockList()
        }
        .toolbar {
            EditButton()
        }
    }
}

struct RockListView_Previews: PreviewProvider {
    static var previews: some View {
        RockListView(viewModel: .init(userId: "aaa"))
    }
}

import SwiftUI
import Resolver

struct RockListView: View {

    @StateObject private var viewModel: RockListViewModelV2 = Resolver.resolve()

    var body: some View {
        NavigationView {
            List(viewModel.rocks) {
                ListRowView(
                    imageURL: $0.headerUrl,
                    iconImage: UIImage.AssetsImages.rockFill,
                    title: $0.name,
                    firstLabel: "登録日",
                    firstText: $0.createdAt.string(dateStyle: .medium),
                    secondLabel: "住所",
                    secondText: $0.address,
                    thirdText: $0.desc
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("登録した岩一覧")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RockListView_Previews: PreviewProvider {
    static var previews: some View {
        RockListView()
    }
}

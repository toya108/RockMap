import SwiftUI

struct HomeView: View {

    @StateObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            VStack {
                SearchView(searchText: $viewModel.searchText) {
                    viewModel.resetSearchText()
                }
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await viewModel.setupBindings()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init())
    }
}

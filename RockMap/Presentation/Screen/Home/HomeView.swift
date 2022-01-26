import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @FocusState var isFocusedSearchField: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                SearchView(
                    searchText: $viewModel.searchText,
                    isFocusedSearchField: _isFocusedSearchField
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                if isFocusedSearchField && viewModel.searchText.isEmpty {
                    SearchHistoryView()
                    Spacer()
                } else if isFocusedSearchField {
                    Spacer()
                } else {
                    CategoryListView(selectedCategory: $viewModel.selectedCategory)
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

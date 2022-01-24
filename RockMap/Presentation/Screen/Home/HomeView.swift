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
                ) {
                    viewModel.resetSearchText()
                }
                if isFocusedSearchField && viewModel.searchText.isEmpty {
                    SearchHistoryView()
                    Spacer()
                } else if isFocusedSearchField {
                    Spacer()
                } else {
                    CategoryListView(selectedCategory: $viewModel.selectedCategory)
                }
            }
            .padding()
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

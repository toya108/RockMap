import SwiftUI

struct SearchRootView: View {
    @StateObject var viewModel: SearchRootViewModel
    @FocusState var isFocusedSearchField: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                SearchView(
                    isPresentedSearchFilter: $viewModel.isPresentedSearchFilter,
                    searchText: $viewModel.searchCondition.searchText,
                    isFocusedSearchField: _isFocusedSearchField
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                if isFocusedSearchField && viewModel.searchCondition.searchText.isEmpty {
                    SearchHistoryView()
                    Spacer()
                } else {
                    if viewModel.searchCondition.searchText.isEmpty {
                        CategoryListView(selectedCategory: $viewModel.selectedCategory)
                    } else {
                        RockSearchView(viewModel: .init(), searchCondition: viewModel.searchCondition)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.isPresentedSearchFilter) {
            SearchFilterView(
                selectedCategory: $viewModel.selectedCategory,
                viewModel: .init()
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRootView(viewModel: .init())
    }
}

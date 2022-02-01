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
                ).padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                ZStack {
                    VStack {
                        SearchHistoryView()
                        Spacer()
                    }
                    .opacity(isFocusedSearchField && viewModel.searchCondition.searchText.isEmpty ? 1 : 0)
                    CategoryListView(selectedCategory: $viewModel.selectedCategory)
                        .opacity(!isFocusedSearchField && viewModel.searchCondition.searchText.isEmpty ? 1 : 0)
                    RockSearchView(
                        viewModel: .init(),
                        searchCondition: viewModel.searchCondition
                    )
                    .opacity(!isFocusedSearchField && viewModel.searchCondition.searchText.isEmpty ? 0 : 1)
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

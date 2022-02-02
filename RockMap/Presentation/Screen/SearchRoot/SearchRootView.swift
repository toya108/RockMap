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
                    .opacity(shouldShowSearchHistory ? 1 : 0)
                    CategoryListView(selectedCategory: $viewModel.selectedCategory)
                        .opacity(shouldShowCategoryList ? 1 : 0)
                    searchResultView
                        .opacity(shouldShowCategoryList ? 0 : 1)
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

    private var shouldShowSearchHistory: Bool {
        isFocusedSearchField && viewModel.searchCondition.searchText.isEmpty
    }

    private var shouldShowCategoryList: Bool {
        !isFocusedSearchField && viewModel.searchCondition.searchText.isEmpty
    }

    @ViewBuilder
    private var searchResultView: some View {
        switch viewModel.selectedCategory {
            case .rock:
                RockSearchView(viewModel: .init(), searchCondition: viewModel.searchCondition)
            case .course:
                CourseSearchView(viewModel: .init(), searchCondition: viewModel.searchCondition)
            case .user:
                UserSearchView(viewModel: .init(), searchCondition: viewModel.searchCondition)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRootView(viewModel: .init())
    }
}

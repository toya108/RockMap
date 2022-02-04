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
                    disabledFilterButton: $viewModel.disabledFilterButton,
                    isFocusedSearchField: _isFocusedSearchField
                ).padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                CategoryTabView(selectedCategory: $viewModel.selectedCategory)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                ZStack {
                    CategoryListView(selectedCategory: $viewModel.selectedCategory)
                        .opacity(viewModel.searchCondition.searchText.isEmpty ? 1 : 0)
                    searchResultView
                        .opacity(!viewModel.searchCondition.searchText.isEmpty ? 1 : 0)
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
        .sheet(isPresented: $viewModel.isPresentedSearchFilter) {
            SearchFilterView(
                selectedCategory: $viewModel.selectedCategory,
                viewModel: .init()
            )
        }
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

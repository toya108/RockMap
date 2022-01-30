import SwiftUI

struct SearchRootView: View {
    @StateObject var viewModel: SearchRootViewModel
    @FocusState var isFocusedSearchField: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                SearchView(
                    isPresentedSearchFilter: $viewModel.isPresentedSearchFilter,
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

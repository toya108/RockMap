import SwiftUI

struct CategoryListView: View {

    @ObservedObject var searchRootViewModel: SearchRootViewModel

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $searchRootViewModel.selectedCategory) {
                ForEach(CategoryKind.allCases) {
                    switch $0 {
                        case .rock:
                            RockListView(
                                viewModel: .init(),
                                searchRootViewModel: searchRootViewModel
                            )
                            .tag($0).frame(width: geometry.size.width)

                        case .course:
                            CourseListView(
                                viewModel: .init(),
                                searchRootViewModel: searchRootViewModel
                            )
                            .tag($0).frame(width: geometry.size.width)

                        case .user:
                            UserListView(viewModel: .init())
                                .tag($0).frame(width: geometry.size.width)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView(searchRootViewModel: .init())
    }
}

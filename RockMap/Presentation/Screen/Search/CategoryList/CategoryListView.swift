import SwiftUI

struct CategoryListView: View {

    @Binding var selectedCategory: CategoryKind

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedCategory) {
                ForEach(CategoryKind.allCases) {
                    switch $0 {
                        case .rock:
                            RockListView(viewModel: .init())
                                .tag($0).frame(width: geometry.size.width)

                        case .course:
                            CourseListView(viewModel: .init())
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
        CategoryListView(selectedCategory: .constant(.rock))
    }
}

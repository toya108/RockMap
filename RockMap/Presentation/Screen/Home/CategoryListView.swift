import SwiftUI

struct CategoryListView: View {

    @Binding var selectedCategory: CategoryKind

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Picker("", selection: $selectedCategory) {
                    ForEach(CategoryKind.allCases) {
                        Text($0.name).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                TabView(selection: $selectedCategory) {
                    ForEach(CategoryKind.allCases) {
                        $0.view.tag($0).frame(width: geometry.size.width)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.Pallete.primaryGreen
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor.white], for: .selected
            )
        }
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView(selectedCategory: .constant(.rock))
    }
}

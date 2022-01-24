import SwiftUI

struct CategoryListView: View {

    @Binding var selectedCategory: CategoryKind

    var body: some View {
        VStack {
            Picker("カテゴリ", selection: $selectedCategory) {
                ForEach(CategoryKind.allCases) {
                    Text($0.name).tag($0)
                }
            }
            .pickerStyle(.segmented)
            ScrollView {
                HStack {
                    ForEach(CategoryKind.allCases) {
                        Text($0.name)
                    }
                }
            }
        }
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView(selectedCategory: .constant(.rock))
    }
}

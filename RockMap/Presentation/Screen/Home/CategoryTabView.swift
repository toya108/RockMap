import SwiftUI

struct CategoryTabView: View {

    @Binding var selectedCategory: CategoryKind

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    ForEach(CategoryKind.allCases) {
                        Color(uiColor: UIColor.Pallete.primaryGreen)
                            .opacity($0 == selectedCategory ? 1.0 : 0.0)
                            .frame(height: 1.0)
                    }
                }
            }
            HStack {
                ForEach(CategoryKind.allCases) { category in
                    Button(
                        action: {
                            selectedCategory = category
                        },
                        label: {
                            HStack {
                                category.icon
                                Text(category.name).fontWeight(.semibold)
                            }
                            .foregroundColor(
                                category == selectedCategory
                                ? Color(uiColor: UIColor.Pallete.primaryGreen)
                                : Color.secondary
                            )
                            .frame(maxWidth: .infinity)
                        }
                    )
                }
            }
        }
        .frame(maxHeight: 44.0)
    }
}


struct CategoryTabView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryTabView(selectedCategory: .constant(.rock))
    }
}

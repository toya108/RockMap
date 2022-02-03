import SwiftUI

struct SearchFilterView: View {

    @Binding var selectedCategory: CategoryKind
    @StateObject var viewModel: SearchFilterViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                switch selectedCategory {
                    case .rock:
                        Picker("岩質", selection: $viewModel.lithology) {
                            ForEach(Entity.Rock.Lithology.allCases) {
                                Text($0.name).tag($0)
                            }
                        }
                        // season
                        // prefecture

                    case .course:
                        Text("aaa")
                        // grade
                        // shape

                    case .user:
                        Text("aaa")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("絞り込み")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("リセット") {

                    }.foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { dismiss() },
                        label: {
                            Image(uiImage: UIImage.SystemImages.xmark.withRenderingMode(.alwaysTemplate))
                        }
                    ).foregroundColor(.primary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFilterView(selectedCategory: .constant(.rock), viewModel: .init())
    }
}

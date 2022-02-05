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
                                Text($0.name).tag($0 as Entity.Rock.Lithology?  )
                            }
                        }
                        SeasonRowView(selectedSeasons: $viewModel.seasons)
                        Picker("都道府県", selection: $viewModel.prefecture) {
                            ForEach(Resources.Prefecture.allCases) {
                                Text($0.nameWithSuffix).tag($0 as Resources.Prefecture?)
                            }
                        }

                    case .course:
                        Picker("グレード", selection: $viewModel.grade) {
                            ForEach(Entity.Course.Grade.allCases) {
                                Text($0.name).tag($0 as Entity.Course.Grade?)
                            }
                        }
                        ShapeRowView(selectedShapes: $viewModel.shapes)

                    case .user:
                        Color.clear
                }
                HStack {
                    Spacer()
                    Button {

                    } label: {
                        Text("条件を適用").fontWeight(.semibold)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(Color(uiColor: UIColor.Pallete.primaryGreen))
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("絞り込み")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("リセット") {
                        viewModel.reset()
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { dismiss() },
                        label: {
                            Resources.Images.System.xmark.image
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

import SwiftUI

struct SearchFilterView: View {

    @Binding var selectedCategory: CategoryKind
    @Binding var searchCondition: SearchCondition
    @State private var area: String = ""
    @StateObject var viewModel: SearchFilterViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                switch selectedCategory {
                    case .rock:
                        Section(LocalizedStringKey("area")) {
                            TextField("text_area_placeholder", text: $viewModel.area)
                                .onAppear {
                                    viewModel.area = searchCondition.area
                                }
                        }

                    case .course:
                        Picker("grade", selection: $viewModel.grade) {
                            ForEach(Entity.Course.Grade.allCases) {
                                Text($0.name).tag($0 as Entity.Course.Grade?)
                            }
                        }

                    case .user:
                        Color.clear
                }
                HStack {
                    Spacer()
                    Button {
                        searchCondition = viewModel.makeSearchCondition(text: searchCondition.searchText)
                        dismiss()
                    } label: {
                        Text("apply").fontWeight(.semibold)
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
                    Button("reset") {
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
        .onAppear {
            viewModel.grade = searchCondition.grade
        }
    }
}

struct SearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFilterView(
            selectedCategory: .constant(.rock),
            searchCondition: .constant(.init()),
            viewModel: .init()
        )
    }
}

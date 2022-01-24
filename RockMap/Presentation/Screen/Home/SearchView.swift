import SwiftUI

struct SearchView: View {

    @Binding var searchText: String
    @FocusState var isFocusedSearchField: Bool
    let didTapResetButton: () -> Void

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("なんか", text: $searchText)
                    .focused($isFocusedSearchField)
                Button(
                    action: didTapResetButton,
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .opacity(searchText.isEmpty ? 0 : 1)
                    }
                )
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            Button(
                action: {

                },
                label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.secondary)
                }
            )
        }
    }
}

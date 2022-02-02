import SwiftUI

struct SearchView: View {

    @Binding var isPresentedSearchFilter: Bool
    @Binding var searchText: String
    @FocusState var isFocusedSearchField: Bool

    var body: some View {
        HStack {
            SearchTextField(
                searchText: $searchText,
                isFocusedSearchField: _isFocusedSearchField
            )
            Button(
                action: {
                    isPresentedSearchFilter = true
                },
                label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.primary)
                }
            )
        }
    }
}

struct SearchTextField: View {

    @Binding var searchText: String
    @FocusState var isFocusedSearchField: Bool

    var body: some View {
        HStack {
            Button(
                action: {
                    isFocusedSearchField = true
                },
                label: {
                    Image(systemName: "magnifyingglass")
                }
            )
            TextField("なんか", text: $searchText)
                .focused($isFocusedSearchField)
            Button(
                action: {
                    searchText = ""
                },
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
    }
}

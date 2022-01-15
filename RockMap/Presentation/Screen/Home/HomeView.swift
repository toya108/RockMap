import SwiftUI

struct HomeView: View {

    @StateObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("なんか", text: $viewModel.searchText)
                        .onSubmit {
                            
                        }
                    Button(
                        action: {
                            viewModel.resetSearchText()
                        },
                        label: {
                            Image(systemName: "xmark.circle.fill")
                                .opacity(viewModel.searchText.isEmpty ? 0 : 1)
                        }
                    )
                }
                .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                .foregroundColor(.secondary)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init())
    }
}

actor HomeViewModel: ObservableObject {
    @Published nonisolated var searchText = ""

    @MainActor func resetSearchText() {
        searchText = ""
    }
}

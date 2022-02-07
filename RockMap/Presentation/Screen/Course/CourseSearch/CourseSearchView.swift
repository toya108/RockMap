import SwiftUI

struct CourseSearchView: View {

    @StateObject var viewModel: CourseSearchViewModel
    @ObservedObject var searchRootViewModel: SearchRootViewModel

    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    search()
                }
                .onChange(of: searchRootViewModel.searchCondition) { _ in
                    search()
                }
            switch viewModel.viewState {
                case .standby:
                    Color.clear

                case .loading:
                    ListSkeltonView()

                case .failure:
                    EmptyView(text: .init("text_fetch_course_failed"))

                case .finish:
                    if viewModel.courses.isEmpty {
                        EmptyView(text: .init("text_no_course"))
                    } else {
                        List(viewModel.courses) { course in
                            NavigationLink(
                                destination: CourseDetailView(course: course)
                            ) {
                                ListRowView(course: course)
                                    .onAppear {
                                        additionalLoadIfNeeded(course: course)
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            search()
                        }
                    }
            }
        }
    }

    private func search() {
        Task {
            await viewModel.search(
                condition: searchRootViewModel.searchCondition,
                isAdditional: false
            )
        }
    }

    private func additionalLoadIfNeeded(course: Entity.Course) {
        Task {
            guard await viewModel.shouldAdditionalLoad(course: course) else {
                return
            }
            await viewModel.additionalLoad(condition: searchRootViewModel.searchCondition)
        }
    }
}

struct CourseSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSearchView(viewModel: .init(), searchRootViewModel: .init())
    }
}

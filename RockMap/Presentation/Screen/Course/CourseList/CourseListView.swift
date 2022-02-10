import SwiftUI

struct CourseListView: View {

    @StateObject var viewModel: CourseListViewModel
    @ObservedObject var searchRootViewModel: SearchRootViewModel

    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    load()
                }
                .onChange(of: searchRootViewModel.searchCondition) { _ in
                    load()
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
                            load()
                        }
                    }
            }
        }
    }

    private func load() {
        Task {
            await viewModel.load(condition: searchRootViewModel.searchCondition)
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

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(viewModel: .init(), searchRootViewModel: .init())
    }
}

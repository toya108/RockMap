import SwiftUI

struct CourseSearchView: View {

    @StateObject var viewModel: CourseSearchViewModel
    @ObservedObject var searchCondition: SearchCondition

    var body: some View {
        ZStack {
            Color.clear
                .onAppear {
                    search()
                }
                .onChange(of: searchCondition.searchText) { _ in
                    search()
                }
            switch viewModel.viewState {
                case .standby:
                    Color.clear

                case .loading:
                    ListSkeltonView()

                case .failure:
                    EmptyView(text: .init("text_fetch_course_failed"))
                        .refreshable {
                            refresh()
                        }

                case .finish:
                    if viewModel.courses.isEmpty {
                        EmptyView(text: .init("text_no_course"))
                            .refreshable {
                                refresh()
                            }

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
                            refresh()
                        }
                    }
            }
        }
    }

    private func search() {
        Task {
            await viewModel.search(condition: searchCondition, isAdditional: false)
        }
    }

    private func additionalLoadIfNeeded(course: Entity.Course) {
        Task {
            guard await viewModel.shouldAdditionalLoad(course: course) else {
                return
            }
            await viewModel.additionalLoad(condition: searchCondition)
        }
    }

    private func refresh() {
        Task {
            await viewModel.refresh(condition: searchCondition)
        }
    }

}

struct CourseSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSearchView(viewModel: .init(), searchCondition: .init())
    }
}

import SwiftUI

struct CourseListView: View {

    @StateObject var viewModel: CourseListViewModel

    var body: some View {
        switch viewModel.viewState {
            case .stanby:
                Color.clear.onAppear {
                    Task {
                        await viewModel.load()
                    }
                }

            case .loading:
                ListSkeltonView()

            case .failure(let error):
                Color.clear

            case .finish:
                if viewModel.courses.isEmpty {
                    EmptyView(text: .init("text_no_course_registerd_yet"))
                        .refreshable {
                            refresh()
                        }

                } else {
                    List(viewModel.courses) { course in
                        NavigationLink(
                            destination: CourseDetailView(course: course)
                        ) {
                            ListRowView(
                                imageURL: course.headerUrl,
                                iconImage: UIImage.AssetsImages.rockFill,
                                title: course.name,
                                firstLabel: .init("registered_date"),
                                firstText: course.createdAt.string(dateStyle: .medium),
                                secondLabel: .init("grade"),
                                secondText: course.grade.name,
                                thirdText: course.desc
                            )
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

    private func load() {
        Task {
            await viewModel.load()
        }
    }

    private func additionalLoadIfNeeded(course: Entity.Course) {
        Task {
            guard await viewModel.shouldAdditionalLoad(course: course) else {
                return
            }
            await viewModel.load()
        }
    }

    private func refresh() {
        Task {
            await viewModel.refresh()
        }
    }

}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(viewModel: .init())
    }
}

import SwiftUI
import SkeletonUI

struct ClimbedCourseListView: View {

    @StateObject var viewModel: ClimbedCourseListViewModel

    var body: some View {
        switch viewModel.viewState {
            case .standby:
                Color.clear.onAppear {
                    self.viewModel.load()
                }

            case .loading:
                ListSkeltonView().padding()

            case .failure:
                EmptyView(text: .init("text_fetch_course_failed"))

            case .finish:
                if viewModel.climbCourses.isEmpty {
                    EmptyView(text: .init("text_no_course"))
                        .refreshable {
                            viewModel.load()
                        }
                } else {
                    List(viewModel.climbCourses) { climbedCourse in
                        NavigationLink(
                            destination: CourseDetailView(course: climbedCourse.course)
                        ) {
                            ListRowView(course: climbedCourse.course, record: climbedCourse.record)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.load()
                    }
                }
        }
    }
}

struct ClimbedCourseListView_Previews: PreviewProvider {
    static var previews: some View {
        ClimbedCourseListView(viewModel: .init(userId: ""))
    }
}

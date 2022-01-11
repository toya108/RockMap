import SwiftUI
import SkeletonUI

struct CourseListView: View {

    @StateObject var viewModel: CourseListViewModelV2

    var body: some View {
        if viewModel.courses.isEmpty {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("text_no_rock_registerd_yet")
            }
            .onAppear {
                viewModel.fetchCourses()
            }
        } else if viewModel.isLoading {
            Color.clear.skeleton(with: true)
                .shape(type: .rectangle)
                .multiline(lines: 8, spacing: 4)
                .padding()
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
                        secondLabel: .init("グレード"),
                        secondText: course.grade.name,
                        thirdText: course.desc
                    )
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("delete", role: .destructive) {
                        viewModel.editingCourse = course
                        viewModel.isPresentedDeleteCourseAlert = true
                    }
                    Button("edit") {
                        viewModel.editingCourse = course
                        viewModel.isPresentedCourseRegister = true
                    }
                }
            }
            .refreshable {
                viewModel.fetchCourses()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .didCourseRegisterFinished)
            ) { _ in
                viewModel.fetchCourses()
            }
            .alert(
                "text_delete_rock_title",
                isPresented: $viewModel.isPresentedDeleteCourseAlert,
                actions: {
                    Button("delete", role: .destructive) {
                        viewModel.delete()
                    }
                    Button("cancel", role: .cancel) {
                        viewModel.isPresentedDeleteCourseAlert = false
                    }
                },
                message: {
                    Text("text_delete_rock_message")
                }
            )
            .alert(
                "text_delete_rock_failure_title",
                isPresented: $viewModel.isPresentedDeleteFailureAlert,
                actions: {
                    Button("yes") {}
                },
                message: {
                    Text(viewModel.deleteError?.localizedDescription ?? "")
                }
            )
            .sheet(isPresented: $viewModel.isPresentedCourseRegister) {
                if let rock = viewModel.editingCourse {
                    CourseRegisterView(registerType: .edit(rock)).interactiveDismissDisabled(true)
                }
            }
        }
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(viewModel: .init(userId: "aaa"))
    }
}

import SwiftUI

struct RegisteredCourseListView: View {

    @StateObject var viewModel: RegisteredCourseListViewModel

    var body: some View {
        switch viewModel.viewState {
            case .standby:
                Color.clear.onAppear {
                    viewModel.fetchCourses()
                }

            case .loading:
                ListSkeltonView().padding()

            case .failure(let error):
                Color.clear
                    .alert(
                        "text_delete_failure_title",
                        isPresented: $viewModel.isPresentedDeleteFailureAlert,
                        actions: {
                            Button("yes") {}
                        },
                        message: {
                            Text(error?.localizedDescription ?? "")
                        }
                    )
            case .finish:
                if viewModel.courses.isEmpty {
                    EmptyView(text: .init("text_no_course_registerd_yet"))
                        .refreshable {
                            viewModel.fetchCourses()
                        }
                } else {
                    List(viewModel.courses) { course in
                        NavigationLink(
                            destination: CourseDetailView(course: course)
                        ) {
                            ListRowView(course: course)
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
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchCourses()
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: .didCourseRegisterFinished)
                    ) { _ in
                        viewModel.fetchCourses()
                    }
                    .alert(
                        "text_delete_course_title",
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
                            Text("text_delete_course_message")
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
}

struct RegisteredCourseListView_Previews: PreviewProvider {
    static var previews: some View {
        RegisteredCourseListView(viewModel: .init(userId: "aaa"))
    }
}

import SwiftUI

struct CourseListView: View {

    @StateObject var viewModel: CourseListViewModel

    var body: some View {
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
                    Task {
                        guard await viewModel.shouldAdditionalLoal(course: course) else {
                            return
                        }
                        await viewModel.additionalLoad()
                    }
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            Task {
                await viewModel.load()
            }
        }
        .refreshable {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(viewModel: .init())
    }
}

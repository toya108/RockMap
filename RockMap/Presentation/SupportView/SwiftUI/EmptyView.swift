import SwiftUI

struct EmptyView: View {

    private let text: LocalizedStringKey

    init(text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(text)
        }
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView(text: "text_no_course_registerd_yet")
    }
}

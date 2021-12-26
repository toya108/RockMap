import SwiftUI

struct EntireTappableRowView<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            content
            Spacer()
        }
        .contentShape(Rectangle())
    }

}

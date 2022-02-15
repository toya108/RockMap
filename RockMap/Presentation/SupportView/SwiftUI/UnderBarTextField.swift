import SwiftUI

struct UnderBarTextField: View {

    @Binding private var text: String
    private let placeHolder: LocalizedStringKey

    init(_ placeHolder: LocalizedStringKey, text: Binding<String>) {
        self._text = text
        self.placeHolder = placeHolder
    }

    var body: some View {
        VStack(spacing: 8) {
            TextField(placeHolder, text: $text)
            Divider()
        }
    }
}

struct UnderBarTextField_Previews: PreviewProvider {
    static var previews: some View {
        UnderBarTextField(.init(""), text: .constant(""))
    }
}

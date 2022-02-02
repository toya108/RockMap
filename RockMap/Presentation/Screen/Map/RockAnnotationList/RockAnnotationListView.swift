import SwiftUI

protocol RockAnnotationListViewDelegate: AnyObject {
    func didSelectRow(rock: Entity.Rock)
}

struct RockAnnotationListView: View {

    @State private var rocks: [Entity.Rock]

    // swiftlint:disable weak_delegate
    var delegate: RockAnnotationListViewDelegate?

    init(rocks: [Entity.Rock]) {
        self.rocks = rocks
    }

    var body: some View {
        List(rocks) { rock in
            ListRowView(rock: rock)
                .onTapGesture {
                    delegate?.didSelectRow(rock: rock)
                }
        }
        .listStyle(.plain)
    }
}

struct RockAnnotationListView_Previews: PreviewProvider {
    static var previews: some View {
        RockAnnotationListView(rocks: [])
    }
}

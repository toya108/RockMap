import SwiftUI

struct RockAnnotationListView: View {

    @State private var rocks: [Entity.Rock]

    // swiftlint:disable weak_delegate
    var delegate: RockAnnotationTableViewDelegate?

    init(rocks: [Entity.Rock]) {
        self.rocks = rocks
    }

    var body: some View {
        List(rocks) { rock in
            ListRowView(
                imageURL: rock.headerUrl,
                iconImage: UIImage.AssetsImages.rockFill,
                title: rock.name,
                firstLabel: .init("registered_date"),
                firstText: rock.createdAt.string(dateStyle: .medium),
                secondLabel: .init("address"),
                secondText: rock.address,
                thirdText: rock.desc
            )
            .onTapGesture {
                delegate?.didSelectRockAnnotaitonCell(rock: rock)
            }
        }
    }
}

struct RockAnnotationListView_Previews: PreviewProvider {
    static var previews: some View {
        RockAnnotationListView(rocks: [])
    }
}

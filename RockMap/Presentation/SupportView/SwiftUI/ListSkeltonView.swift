import SwiftUI
import SkeletonUI

struct ListSkeltonView: View {
    var body: some View {
        Color.clear.skeleton(with: true)
            .shape(type: .rectangle)
            .multiline(lines: 8, spacing: 4)
    }
}

struct ListSkeltonView_Previews: PreviewProvider {
    static var previews: some View {
        ListSkeltonView()
    }
}

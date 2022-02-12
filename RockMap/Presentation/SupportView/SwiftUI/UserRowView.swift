import SwiftUI

struct UserRowView: View {

    let user: Entity.User

    var body: some View {
        NavigationLink(
            destination: MyPageView(userKind: .other(user: user))
        ) {
            HStack {
                DefaultAsyncImage(url: user.photoURL)
                    .clipShape(Circle())
                    .frame(width: 44, height: 44)
                Text(user.name)
            }
            .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}

struct UserRowView_Previews: PreviewProvider {
    static var previews: some View {
        UserRowView(user: Entity.User.dummy)
    }
}

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(uiImage: UIImage.AssetsImages.mountainBackGround)
                .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 16) {
                Text("RockMap")
                    .font(.system(size: 33, weight: .heavy))
                Text("Hello Climbers!\nLet's share rocks & courses!")
                    .font(.system(size: 18, weight: .heavy))
                Text("RockMapはクライマーのための地図アプリです。\n岩と課題の情報をシェアしましょう！")
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            VStack {
                HStack {
                    Button(
                        action: {

                        },
                        label: {
                            Text("Login")
                                .font(.system(size: 20, weight: .heavy, design: .default))
                                .padding(8)
                                .foregroundColor(Color(uiColor: .white))
                                .background(Color(uiColor: UIColor.Pallete.primaryGreen))
                        }
                    )
                    .cornerRadius(8)
                    Button(
                        action: {

                        },
                        label: {
                            Text("Guest Login")
                                .font(.system(size: 20, weight: .heavy, design: .default))
                                .padding(8)
                                .foregroundColor(Color(uiColor: UIColor.Pallete.primaryGreen))
                        }
                    )
                        .cornerRadius(8)
                    Spacer()
                }
                HStack {
                    Button("利用規約") {

                    }
                    .font(.system(size: 14))

                    Button("プライバシーポリシー") {

                    }
                    .font(.system(size: 14))
                    Spacer()
                }
            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
        }
    }
}

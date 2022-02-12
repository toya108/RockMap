import SwiftUI
import PhotosUI

struct EditProfileView: View {

    @ObservedObject var viewModel: EditProfileViewModelV2

    private var configuration: PHPickerConfiguration {
        var configration = PHPickerConfiguration()
        configration.selectionLimit = 1
        configration.filter = .images
        return configration
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Button {
                        viewModel.isPresentedHeaderPicker = true
                    } label: {
                        if let data = viewModel.headerData {
                            Image(uiImage: UIImage(data: data)).resizable().scaledToFill()
                        } else if let url = viewModel.headerURL {
                            DefaultAsyncImage(url: url)
                        } else {
                            Resources.Images.System.cameraFill.image
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                    .clipped()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    Button {
                        viewModel.isPresentedIconPicker = true
                    } label: {
                        if let data = viewModel.iconData {
                            Image(uiImage: UIImage(data: data)).resizable().scaledToFill()
                        } else if let url = viewModel.iconURL {
                            DefaultAsyncImage(url: url)
                        } else {
                            Resources.Images.System.cameraFill.image
                        }
                    }
                    .frame(maxWidth: 64, minHeight: 64)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .padding(EdgeInsets(top: -24, leading: 8, bottom: 0, trailing: 0))

                    Section("名前") {
                        TextField("名前", text: $viewModel.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        if !viewModel.isValidName {
                            Text("※名前は必須です")
                                .foregroundColor(Color(uiColor: UIColor.Pallete.primaryPink))
                                .font(.caption)
                                .padding(.bottom, 4)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    Section("自己紹介") {
                        TextEditor(text: $viewModel.introduction)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(
                                Color(uiColor: .systemGray5),
                                lineWidth: 0.5
                            ))
                            .frame(minHeight: 64)
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    Section("SNSリンク") {
                        HStack {
                            Entity.User.SocialLinkType.facebook.icon.image
                                .resizable()
                                .frame(maxWidth: 24, maxHeight: 24)
                                .foregroundColor(.gray)
                            TextField("@", text: $viewModel.facebook)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Entity.User.SocialLinkType.twitter.icon.image
                                .resizable()
                                .frame(maxWidth: 24, maxHeight: 24)
                                .foregroundColor(.gray)
                            TextField("@", text: $viewModel.twitter)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Entity.User.SocialLinkType.instagram.icon.image
                                .resizable()
                                .frame(maxWidth: 24, maxHeight: 24)
                                .foregroundColor(.gray)
                            TextField("@", text: $viewModel.instagram)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Entity.User.SocialLinkType.other.icon.image
                                .resizable()
                                .frame(maxWidth: 24, maxHeight: 24)
                                .foregroundColor(.gray)
                            TextField("Webサイトを追加", text: $viewModel.other)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("プロフィール編集")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            viewModel.isPresentedDismissConfirmation = true
                        },
                        label: {
                            Resources.Images.System.xmark.image
                        }
                    ).foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.startUpdateSequences()
                    }
                    .foregroundColor(Color(uiColor: UIColor.Pallete.primaryGreen))
                }
            }
            .onChange(of: viewModel.userUpdateState) { state in
                switch state {
                    case .loading, .standby:
                        break

                    case .failure:
                        self.viewModel.isPresentedUserUpdateAlert = true

                    case .finish:
                        NotificationCenter.default.post(name: .didProfileEditFinished, object: nil)
                        self.dismiss()
                }
            }
            .confirmationDialog(
                "編集内容を破棄しますか？",
                isPresented: $viewModel.isPresentedDismissConfirmation,
                titleVisibility: .visible
            ) {
                Button("破棄", role: .destructive) {
                    self.dismiss()
                }
                Button("キャンセル", role: .cancel) {
                    viewModel.isPresentedDismissConfirmation = false
                }
            }
            .alert(
                "画像の取得に失敗しました。",
                isPresented: $viewModel.isPresentedPickerFailureAlert,
                actions: {
                    Button("OK") { viewModel.isPresentedPickerFailureAlert = false }
                },
                message: {
                    Text("reason: \(viewModel.pickerState.error?.localizedDescription ?? "")")
                }
            )
            .alert(
                "編集に失敗しました。",
                isPresented: $viewModel.isPresentedUserUpdateAlert,
                actions: {
                    Button("OK") { viewModel.isPresentedUserUpdateAlert = false }
                },
                message: {
                    Text("reason: \(viewModel.userUpdateState.error?.localizedDescription ?? "")")
                }
            )
            .sheet(isPresented: $viewModel.isPresentedIconPicker) {
                PHPickerView(
                    state: $viewModel.pickerState,
                    configuration: configuration,
                    imageType: .icon
                )
            }
            .sheet(isPresented: $viewModel.isPresentedHeaderPicker) {
                PHPickerView(
                    state: $viewModel.pickerState,
                    configuration: configuration,
                    imageType: .header
                )
            }
            if viewModel.userUpdateState.isLoading {
                ActivityIndicatorView()
            }
        }
    }

    private func dismiss() {
        let window = UIApplication.shared.keyWindow
        window?.rootViewController?.getVisibleViewController()?.dismiss(animated: true)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(viewModel: .init(user: .init(id: "", createdAt: Date(), name: "")))
    }
}

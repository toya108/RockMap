import SwiftUI
import PhotosUI

struct EditProfileView: View {

    @ObservedObject var viewModel: EditProfileViewModel

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
                    .overlay(Circle().stroke(Color(uiColor: .systemBackground), lineWidth: 4))
                    .padding(EdgeInsets(top: -24, leading: 8, bottom: 0, trailing: 0))

                    Section(LocalizedStringKey("name")) {
                        TextField("name", text: $viewModel.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        if !viewModel.isValidName {
                            Text("text_empty_name_annotation")
                                .foregroundColor(Color(uiColor: UIColor.Pallete.primaryPink))
                                .font(.caption)
                                .padding(.bottom, 4)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    Section(LocalizedStringKey("introduction")) {
                        TextEditor(text: $viewModel.introduction)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(
                                Color(uiColor: .systemGray5),
                                lineWidth: 0.5
                            ))
                            .frame(minHeight: 64)
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    Section(LocalizedStringKey("sns_links")) {
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
                            TextField("web_textfield_placeholder", text: $viewModel.other)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("edit_profile")
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
                    Button("save") {
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
                "discard_change_alert_title",
                isPresented: $viewModel.isPresentedDismissConfirmation,
                titleVisibility: .visible
            ) {
                Button("discard", role: .destructive) {
                    self.dismiss()
                }
                Button("cancel", role: .cancel) {
                    viewModel.isPresentedDismissConfirmation = false
                }
            }
            .alert(
                "text_failed_fetch_image_alert_title",
                isPresented: $viewModel.isPresentedPickerFailureAlert,
                actions: {
                    Button("ok") { viewModel.isPresentedPickerFailureAlert = false }
                },
                message: {
                    Text("reason: \(viewModel.pickerState.error?.localizedDescription ?? "")")
                }
            )
            .alert(
                "text_failed_update_user_alert_title",
                isPresented: $viewModel.isPresentedUserUpdateAlert,
                actions: {
                    Button("ok") { viewModel.isPresentedUserUpdateAlert = false }
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

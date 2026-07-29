import SwiftUI
import PhotosUI

/// 10g — avatar ships as an SF Symbol; becomes the user's photo when they add
/// one. Photo is OPTIONAL and stays ON DEVICE only (never uploaded).
struct ProfileView: View {
    @State private var avatar: UIImage?    // persist to app container only
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    avatarView.padding(.top, 22)
                    RaisedCard(radius: 18) {
                        VStack(spacing: 0) {
                            row(icon: "person.crop.circle", title: "Photo",
                                subtitle: "OPTIONAL \(MVMTheme.dot) STAYS ON DEVICE", action: "Add")
                            Divider().overlay(MVMTheme.hairline)
                            row(icon: "camera", title: "Take a photo", subtitle: nil, action: nil)
                        }
                    }
                    BadgesView()
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var avatarView: some View {
        Group {
            if let avatar {
                Image(uiImage: avatar).resizable().scaledToFill()
            } else {
                // Default: SF Symbol on raised circle — never a placeholder photo.
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(MVMTheme.amber.opacity(0.85))
            }
        }
        .frame(width: 96, height: 96)
        .background(MVMTheme.cardGradient)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
    }

    private func row(icon: String, title: String, subtitle: String?, action: String?) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 19))
                .foregroundStyle(MVMTheme.amber.opacity(0.85))
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MVMTheme.text)
                if let subtitle {
                    Text(subtitle).font(MVMTheme.mono(11))
                        .foregroundStyle(MVMTheme.textFaint)
                        .lineLimit(1).fixedSize()
                }
            }
            Spacer()
            if let action {
                Text(action).font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MVMTheme.amber)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MVMTheme.text.opacity(0.4))
            }
        }
        .padding(.horizontal, 16).frame(minHeight: 56)
    }
}

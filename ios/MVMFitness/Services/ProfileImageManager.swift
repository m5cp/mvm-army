import SwiftUI
import PhotosUI

@Observable
final class ProfileImageManager {
    var selectedItem: PhotosPickerItem?
    var profileImage: UIImage?
    var selectedAvatarIndex: Int?

    static let avatarSymbols = [
        "shield.fill",
        "star.fill",
        "bolt.fill",
        "flame.fill",
        "figure.strengthtraining.traditional",
        "figure.run",
        "medal.fill",
        "trophy.fill"
    ]

    init() {
        loadSavedImage()
        selectedAvatarIndex = UserDefaults.standard.object(forKey: "profileAvatarIndex") as? Int
    }

    func loadSavedImage() {
        guard let data = try? Data(contentsOf: imageURL) else { return }
        profileImage = UIImage(data: data)
    }

    func saveImage(_ image: UIImage) {
        profileImage = image
        selectedAvatarIndex = nil
        UserDefaults.standard.removeObject(forKey: "profileAvatarIndex")
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: imageURL)
    }

    func selectAvatar(_ index: Int) {
        selectedAvatarIndex = index
        profileImage = nil
        UserDefaults.standard.set(index, forKey: "profileAvatarIndex")
        try? FileManager.default.removeItem(at: imageURL)
    }

    func removeImage() {
        profileImage = nil
        selectedAvatarIndex = nil
        UserDefaults.standard.removeObject(forKey: "profileAvatarIndex")
        try? FileManager.default.removeItem(at: imageURL)
    }

    func handlePickerItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        let resized = resizeImage(uiImage, maxSize: 400)
        saveImage(resized)
    }

    private var imageURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("profile_image.jpg")
    }

    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        if ratio >= 1 { return image }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

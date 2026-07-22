import Foundation

/// Central place for the app's public App Store link, used across share cards and captions.
enum AppLinks {
    static let appStoreID = "6746823289"
    static let appStoreURLString = "https://apps.apple.com/app/mvm-fitness/id\(appStoreID)"

    /// Appended to share captions so recipients can find and download the app.
    static var shareSuffix: String {
        "\n\nFree on the App Store\n\(appStoreURLString)"
    }
}

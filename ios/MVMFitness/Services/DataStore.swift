import Foundation

/// File-based persistent store. Same API as LocalStore so call sites swap mechanically.
/// - Local: Application Support/MVMData/<key>.json (atomic writes)
/// - iCloud: mirrored to the ubiquity container's Documents/MVMData when available;
///   on load, the newer of local vs iCloud wins (last-write-wins by modification date).
enum DataStore {

    private static let folderName = "MVMData"

    private static var localFolder: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private static var iCloudFolder: URL? {
        guard let container = FileManager.default.url(forUbiquityContainerIdentifier: nil) else { return nil }
        let folder = container.appendingPathComponent("Documents/\(folderName)", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private static func localURL(_ key: String) -> URL {
        localFolder.appendingPathComponent("\(key).json")
    }

    // MARK: - Public API (matches LocalStore exactly)

    static func save<T: Codable>(_ value: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: localURL(key), options: [.atomic])
            if let cloud = iCloudFolder {
                try? data.write(to: cloud.appendingPathComponent("\(key).json"), options: [.atomic])
            }
        } catch {
            print("DataStore save failed for \(key): \(error.localizedDescription)")
        }
    }

    static func load<T: Codable>(_ type: T.Type, forKey key: String, fallback: T) -> T {
        let localFile = localURL(key)
        var candidates: [URL] = []
        if FileManager.default.fileExists(atPath: localFile.path) { candidates.append(localFile) }
        if let cloud = iCloudFolder {
            let cloudFile = cloud.appendingPathComponent("\(key).json")
            if FileManager.default.fileExists(atPath: cloudFile.path) { candidates.append(cloudFile) }
        }
        // Newest file wins
        let newest = candidates.max { a, b in
            let da = (try? a.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let db = (try? b.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return da < db
        }
        guard let url = newest, let data = try? Data(contentsOf: url) else { return fallback }
        return (try? JSONDecoder().decode(type, from: data)) ?? fallback
    }

    // MARK: - One-time migration from UserDefaults (LocalStore keys)

    private static let migrationFlag = "dataStoreMigrated_v1"

    /// Copies every legacy UserDefaults-backed record into files. Safe to call repeatedly.
    /// UserDefaults values are intentionally left in place for one release as a backup.
    static func migrateFromUserDefaultsIfNeeded(keys: [String]) {
        guard !UserDefaults.standard.bool(forKey: migrationFlag) else { return }
        for key in keys {
            let fileURL = localURL(key)
            guard !FileManager.default.fileExists(atPath: fileURL.path),
                  let data = UserDefaults.standard.data(forKey: key) else { continue }
            try? data.write(to: fileURL, options: [.atomic])
        }
        UserDefaults.standard.set(true, forKey: migrationFlag)
    }
}

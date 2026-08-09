import Foundation

/// File-based persistent store. Same API as LocalStore so call sites swap mechanically.
/// - Local: Application Support/MVMData/<key>.json (atomic writes)
/// - iCloud: mirrored to the ubiquity container's Documents/MVMData when available;
///   on load, the newer of local vs iCloud wins (last-write-wins by modification date).
///
/// Writes are performed off the calling thread. `url(forUbiquityContainerIdentifier:)`
/// is documented as potentially long-blocking, and the app previously resolved it
/// twice per key on every save — 26 blocking lookups on the main thread for a
/// single `persistAll()`. It is now resolved once and cached.
enum DataStore {

    private static let folderName = "MVMData"

    private static let ioQueue = DispatchQueue(label: "app.rork.mvmfitness.datastore", qos: .utility)

    private static var localFolder: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    /// Resolved at most once for the lifetime of the process.
    private static let iCloudFolder: URL? = {
        guard let container = FileManager.default.url(forUbiquityContainerIdentifier: nil) else { return nil }
        let folder = container.appendingPathComponent("Documents/\(folderName)", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }()

    private static func localURL(_ key: String) -> URL {
        localFolder.appendingPathComponent("\(key).json")
    }

    // MARK: - Public API (matches LocalStore exactly)

    /// Keys that must never leave the device. The Squad roster holds OTHER
    /// soldiers' names, emails and phone numbers, and the app tells the user on
    /// screen that "Squad data stays on this device" — mirroring it into the
    /// owner's personal iCloud contradicted that promise.
    static let deviceOnlyKeys: Set<String> = ["squadData"]

    static func save<T: Codable>(_ value: T, forKey key: String) {
        // Encode on the caller so the value is captured as bytes and the write
        // can safely hop threads.
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            print("DataStore encode failed for \(key): \(error.localizedDescription)")
            return
        }
        let local = localURL(key)
        ioQueue.async {
            do {
                try data.write(to: local, options: [.atomic])
            } catch {
                print("DataStore save failed for \(key): \(error.localizedDescription)")
            }
            if !deviceOnlyKeys.contains(key), let cloud = iCloudFolder {
                try? data.write(to: cloud.appendingPathComponent("\(key).json"), options: [.atomic])
            }
        }
    }

    static func load<T: Codable>(_ type: T.Type, forKey key: String, fallback: T) -> T {
        let localFile = localURL(key)
        var candidates: [URL] = []
        if FileManager.default.fileExists(atPath: localFile.path) { candidates.append(localFile) }
        if !deviceOnlyKeys.contains(key), let cloud = iCloudFolder {
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

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            // Returning the fallback silently means the next persistAll() writes
            // an empty array over the user's real data, locally AND in iCloud —
            // one added non-optional field in a future model would wipe the
            // store permanently. Quarantine the file instead so it is
            // recoverable, and leave a marker so the app can surface it.
            quarantine(url, key: key, reason: error.localizedDescription)
            return fallback
        }
    }

    /// Set when a file failed to decode, so the app can tell the user their data
    /// could not be read instead of silently presenting an empty state.
    private(set) static var lastCorruptionKey: String?

    private static func quarantine(_ url: URL, key: String, reason: String) {
        lastCorruptionKey = key
        print("DataStore decode failed for \(key): \(reason) — quarantining")
        let backup = url.deletingPathExtension().appendingPathExtension("corrupt.json")
        ioQueue.async {
            try? FileManager.default.removeItem(at: backup)
            try? FileManager.default.moveItem(at: url, to: backup)
        }
    }

    // MARK: - Deletion

    /// Removes the backing files for a key, locally and in iCloud. Without this
    /// "Delete All Data" only cleared memory and UserDefaults, so everything
    /// reloaded from disk on the next launch.
    static func delete(forKey key: String) {
        let local = localURL(key)
        ioQueue.async {
            try? FileManager.default.removeItem(at: local)
            if let cloud = iCloudFolder {
                try? FileManager.default.removeItem(at: cloud.appendingPathComponent("\(key).json"))
            }
        }
    }

    static func delete(keys: [String]) {
        keys.forEach { delete(forKey: $0) }
    }

    /// Blocks until every queued write has committed. Writes are asynchronous so
    /// they stay off the main thread, which means a swipe-kill or a jetsam right
    /// after a workout could otherwise lose it. Call this when the scene
    /// backgrounds — it is the only place a synchronous wait is warranted.
    static func flush() {
        ioQueue.sync {}
    }

    /// Every key the app has ever written through this store. Used by
    /// "Delete All Data" so a key added later cannot be quietly left behind.
    static let allKnownKeys: [String] = [
        "currentPlan", "completedRecords", "unitPTPlans", "unitPTFullPlan",
        "scheduledUnitPT", "importedWorkouts", "aftScores", "aftCalculatorResults",
        "wodPlan", "quickStartRecords", "dailyLogs", "serviceTestRecords",
        "todayFunctionalWOD", "shownMilestones", "stepHistory", "squadData"
    ]

    /// Deletes every known store file plus anything else left in the folder,
    /// so nothing survives a wipe just because it was not on the list.
    static func deleteEverything() {
        delete(keys: allKnownKeys)
        let local = localFolder
        ioQueue.async {
            if let contents = try? FileManager.default.contentsOfDirectory(at: local, includingPropertiesForKeys: nil) {
                for file in contents where file.pathExtension == "json" {
                    try? FileManager.default.removeItem(at: file)
                }
            }
            if let cloud = iCloudFolder,
               let contents = try? FileManager.default.contentsOfDirectory(at: cloud, includingPropertiesForKeys: nil) {
                for file in contents where file.pathExtension == "json" {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        }
    }

    /// Earlier builds mirrored every key to iCloud, including the squad roster.
    /// Marking it device-only stops FUTURE writes but leaves other soldiers'
    /// names, emails and phone numbers sitting in the owner's iCloud container.
    /// Remove them once.
    private static let cloudPurgeFlag = "deviceOnlyCloudPurged_v1"

    static func purgeDeviceOnlyKeysFromCloud() {
        guard !UserDefaults.standard.bool(forKey: cloudPurgeFlag) else { return }
        UserDefaults.standard.set(true, forKey: cloudPurgeFlag)
        ioQueue.async {
            guard let cloud = iCloudFolder else { return }
            for key in deviceOnlyKeys {
                try? FileManager.default.removeItem(at: cloud.appendingPathComponent("\(key).json"))
            }
        }
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

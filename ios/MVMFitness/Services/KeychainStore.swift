import Foundation
import Security

/// Minimal string storage backed by the iOS Keychain.
///
/// Used for the small number of values that must survive a reinstall and must
/// not be trivially editable, unlike `UserDefaults` (which lives in a plist a
/// user can rewrite on a jailbroken device, and which is wiped on delete).
///
/// Deliberately not generic or cached: every call talks to the Keychain, so the
/// stored value and the returned value can never drift apart.
nonisolated enum KeychainStore {
    /// `afterFirstUnlockThisDeviceOnly` is the right trade-off here:
    ///
    /// - *afterFirstUnlock* means the value is readable once the device has been
    ///   unlocked a single time following a reboot, so extensions and any early
    ///   launch still see it. It is not readable while the device sits locked
    ///   after a cold boot, which is fine — there is no UI to serve then.
    /// - *thisDeviceOnly* keeps it out of encrypted backups and iCloud Keychain,
    ///   so restoring someone else's backup does not hand over their access.
    private static let accessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

    private static let service = "app.rork.mvmfitness.access"

    private static func query(_ key: String) -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]
    }

    static func string(forKey key: String) -> String? {
        var lookup = query(key)
        lookup[kSecReturnData] = true
        lookup[kSecMatchLimit] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(lookup as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8),
              !value.isEmpty else {
            return nil
        }
        return value
    }

    /// Writes the value, replacing any existing one for the same key.
    @discardableResult
    static func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Update first: SecItemAdd fails with errSecDuplicateItem when a value
        // already exists, and delete-then-add would leave a window with nothing
        // stored if the add failed.
        let updateStatus = SecItemUpdate(
            query(key) as CFDictionary,
            [kSecValueData: data] as CFDictionary
        )
        if updateStatus == errSecSuccess { return true }

        var insert = query(key)
        insert[kSecValueData] = data
        insert[kSecAttrAccessible] = accessibility

        let addStatus = SecItemAdd(insert as CFDictionary, nil)
        if addStatus != errSecSuccess {
            print("[Keychain] write failed for \(key): \(addStatus)")
        }
        return addStatus == errSecSuccess
    }

    static func removeValue(forKey key: String) {
        let status = SecItemDelete(query(key) as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("[Keychain] delete failed for \(key): \(status)")
        }
    }

    /// Wipes every item this app stored, without needing a list of keys.
    ///
    /// Keychain items outlive app deletion, so "Delete All Data" has to clear
    /// them explicitly or the promise that nothing is left behind is false.
    static func removeAll() {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service
        ] as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("[Keychain] wipe failed: \(status)")
        }
    }
}

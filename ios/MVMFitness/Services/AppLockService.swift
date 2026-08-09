import Foundation
import LocalAuthentication
import Observation

/// Wraps Face ID / Touch ID (with automatic device-passcode fallback) for the
/// optional app-launch lock. Mirrors the graceful-degradation pattern used
/// elsewhere in the app: if biometrics aren't available, callers get a clear
/// error message rather than a crash.
@MainActor
@Observable
final class AppLockService {
    enum LockError: LocalizedError {
        case unavailable(String)
        case failed

        var errorDescription: String? {
            switch self {
            case .unavailable(let reason): return reason
            case .failed: return "Authentication failed. Try again."
            }
        }
    }

    /// True once biometric/passcode auth has succeeded for the current app session.
    private(set) var isUnlocked = false
    private(set) var lastError: String?

    /// The biometry type available on this device, for lock-screen copy.
    var biometryLabel: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Passcode"
        }
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Passcode"
        }
    }

    /// Marks the session as locked again (called on background/re-launch).
    func lock() {
        isUnlocked = false
        lastError = nil
    }

    /// Marks the session unlocked without a biometric prompt (used when the
    /// lock preference is off, so no gate is ever shown).
    func unlockWithoutPrompt() {
        isUnlocked = true
        lastError = nil
    }

    @discardableResult
    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // The old copy told the user to "turn off App Lock" — but that
            // toggle lives in Profile, which is BEHIND the lock. With no
            // passcode set there was no way back in short of reinstalling and
            // losing all local data. If the device cannot authenticate at all,
            // the lock cannot be honoured, so disable it rather than trap them.
            lastError = "This device has no passcode, Face ID or Touch ID set up, so App Lock has been turned off. Add one in Settings to use it."
            UserDefaults.standard.set(false, forKey: "appLockEnabled")
            isUnlocked = true
            return true
        }

        let reason = "Unlock MVM Fitness"
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            isUnlocked = success
            lastError = success ? nil : LockError.failed.localizedDescription
            return success
        } catch {
            isUnlocked = false
            lastError = LockError.failed.localizedDescription
            return false
        }
    }
}

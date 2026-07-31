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
            lastError = "Face ID / Touch ID isn't set up on this device. Add one in Settings, or turn off App Lock."
            return false
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

import Foundation
import Observation

/// Grants full Pro access, for free, to a fixed allowlist of people.
///
/// The app deliberately has no accounts — the privacy policy promises no
/// registration and no password — so there is no "login" to key this off. The
/// user enters an email once, it is checked against the list below, and the
/// grant is stored locally on that device. The address is never transmitted
/// anywhere; it is only compared against the constants in this file.
///
/// This is intentionally a plain client-side allowlist. Anyone willing to read
/// the binary could find these addresses and unlock Pro, which is an accepted
/// trade-off: the alternative is a real accounts system and a server, and the
/// people on this list are known individuals, not a revenue segment worth
/// defending.
@Observable
@MainActor
final class ComplimentaryAccessService {
    static let shared = ComplimentaryAccessService()

    /// Everyone at this domain is covered, including any subdomain of it.
    private static let allowedDomains: Set<String> = [
        "hardin.kyschools.us"
    ]

    /// Individually named addresses.
    private static let allowedAddresses: Set<String> = [
        "suemcgee83@gmail.com",
        "audrey.mcgee1524@gmail.com",
        "avamcgee2476@gmail.com",
        "eboliver1911@gmail.com"
    ]

    enum RedeemResult: Equatable {
        case granted
        case notEligible
        case malformed
    }

    private enum Keys {
        static let email = "complimentaryAccessEmail"
    }

    /// The address that unlocked this device, shown back to the user so they
    /// can see which one is active. `nil` means no complimentary grant.
    private(set) var grantedEmail: String?

    var isActive: Bool { grantedEmail != nil }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Re-validate on every launch rather than trusting the stored flag. If
        // this list ever changes, a grant that no longer qualifies falls away
        // instead of living forever in UserDefaults.
        guard let stored = defaults.string(forKey: Keys.email) else { return }
        if Self.isEligible(stored) {
            grantedEmail = stored
        } else {
            defaults.removeObject(forKey: Keys.email)
        }
    }

    @discardableResult
    func redeem(_ rawEmail: String) -> RedeemResult {
        let trimmed = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard Self.canonical(trimmed) != nil else { return .malformed }
        guard Self.isEligible(trimmed) else { return .notEligible }

        grantedEmail = trimmed
        defaults.set(trimmed, forKey: Keys.email)
        return .granted
    }

    /// Lets someone hand a device on, or move their access elsewhere.
    func revoke() {
        grantedEmail = nil
        defaults.removeObject(forKey: Keys.email)
    }

    // MARK: - Matching

    private static func isEligible(_ email: String) -> Bool {
        guard let parsed = canonical(email) else { return false }

        if allowedDomains.contains(where: { parsed.domain == $0 || parsed.domain.hasSuffix(".\($0)") }) {
            return true
        }

        return canonicalAllowedAddresses.contains("\(parsed.local)@\(parsed.domain)")
    }

    private static let canonicalAllowedAddresses: Set<String> = {
        Set(allowedAddresses.compactMap { canonical($0).map { "\($0.local)@\($0.domain)" } })
    }()

    /// Splits and normalizes an address for comparison.
    ///
    /// Gmail ignores dots and everything after a `+` in the local part, so
    /// `audrey.mcgee1524@gmail.com` and `audreymcgee1524+pt@gmail.com` are the
    /// same inbox. Matching those the way Gmail does avoids telling someone on
    /// the list that their own address is not on the list.
    private static func canonical(_ email: String) -> (local: String, domain: String)? {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }

        var local = String(parts[0])
        let domain = String(parts[1])

        guard !local.isEmpty, !domain.isEmpty, domain.contains("."),
              !domain.hasPrefix("."), !domain.hasSuffix(".") else { return nil }

        if domain == "gmail.com" || domain == "googlemail.com" {
            local = String(local.split(separator: "+", omittingEmptySubsequences: false)[0])
            local = local.replacingOccurrences(of: ".", with: "")
            guard !local.isEmpty else { return nil }
            return (local, "gmail.com")
        }

        return (local, domain)
    }
}

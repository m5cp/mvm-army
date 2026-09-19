import Foundation
import Observation

/// Grants full Pro access, for free, without an account.
///
/// Two ways in:
///
/// 1. **An access code** — the main path. One code can be read aloud to a whole
///    team, and it can be rotated or expired if it escapes.
/// 2. **A named email** — for family. These never expire, so they do not depend
///    on a code that may later be rotated.
///
/// The app deliberately has no accounts (the privacy policy promises no
/// registration and no password), so nothing here is transmitted anywhere. Both
/// checks happen against the constants in this file and the result is stored on
/// the device only.
///
/// This is a client-side check by design. Anyone willing to pull apart the
/// binary could find these values, which is why every shared code carries an
/// expiry: a leak then costs one release to fix instead of being permanent.
@Observable
@MainActor
final class ComplimentaryAccessService {
    static let shared = ComplimentaryAccessService()

    // MARK: - Access codes

    nonisolated struct AccessCode: Sendable {
        /// Compared after normalizing, so case and dashes do not matter.
        let code: String
        /// Shown to the user once redeemed, so they know which grant is active.
        let label: String
        /// Last day the code works. Codes are shared out loud and screenshotted;
        /// an expiry means a leak ages out instead of living forever.
        let expires: DateComponents

        var expiryDate: Date? {
            Calendar(identifier: .gregorian).date(from: expires)
        }
    }

    /// Middle dot separator, matching the app's typography rule that compound
    /// values never use a hyphen (hyphens invite a line wrap mid-label).
    private static let separator = "·"

    /// Add a new entry here to issue a code; remove one to kill it immediately.
    ///
    /// The year in a code names the *season it opens*, not the month it dies:
    /// a `26` code covers the 2026-27 year and lapses the following August, so
    /// it stays good through the whole season it was handed out for.
    private static let accessCodes: [AccessCode] = [
        AccessCode(
            code: "BULLDOGS26",
            label: "Bulldogs team access \(separator) 2026-27",
            expires: DateComponents(year: 2027, month: 8, day: 1)
        ),
        AccessCode(
            code: "BULLDOGS27",
            label: "Bulldogs team access \(separator) 2027-28",
            expires: DateComponents(year: 2028, month: 8, day: 1)
        ),
        AccessCode(
            code: "AIRBORNE26",
            label: "Airborne access \(separator) 2026-27",
            expires: DateComponents(year: 2027, month: 8, day: 1)
        ),
        AccessCode(
            code: "BENNY26",
            label: "Benny access \(separator) 2026-27",
            expires: DateComponents(year: 2027, month: 8, day: 1)
        )
    ]

    // MARK: - Email allowlist

    /// Everyone at this domain is covered, including any subdomain.
    private static let allowedDomains: Set<String> = [
        "hardin.kyschools.us"
    ]

    /// Individually named addresses. No expiry.
    private static let allowedAddresses: Set<String> = [
        "suemcgee83@gmail.com",
        "audrey.mcgee1524@gmail.com",
        "avamcgee2476@gmail.com",
        "eboliver1911@gmail.com"
    ]

    // MARK: - State

    nonisolated enum RedeemResult: Equatable {
        case granted(label: String)
        case expired(on: Date)
        case notRecognized
    }

    private enum Keys {
        static let code = "complimentaryAccessCode"
        static let email = "complimentaryAccessEmail"
    }

    /// Human-readable description of the active grant, or `nil` if there is none.
    private(set) var grantLabel: String?

    /// The email that unlocked this device, when that was the route in.
    private(set) var grantedEmail: String?

    var isActive: Bool { grantLabel != nil }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        revalidate()
    }

    /// Re-checks the stored grant against the current rules rather than trusting
    /// a saved flag. A code that has since expired or been pulled from the list
    /// stops working on the next launch instead of persisting forever.
    private func revalidate() {
        if let storedCode = defaults.string(forKey: Keys.code) {
            if let match = Self.matchingCode(storedCode), !Self.isExpired(match) {
                grantLabel = match.label
                return
            }
            defaults.removeObject(forKey: Keys.code)
        }

        if let storedEmail = defaults.string(forKey: Keys.email) {
            if Self.isEligibleEmail(storedEmail) {
                grantedEmail = storedEmail
                grantLabel = storedEmail
                return
            }
            defaults.removeObject(forKey: Keys.email)
        }

        grantLabel = nil
        grantedEmail = nil
    }

    // MARK: - Redeeming

    /// Accepts either an access code or an allowlisted email in one field, so
    /// the user does not have to know which kind of thing they were given.
    @discardableResult
    func redeem(_ rawInput: String) -> RedeemResult {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .notRecognized }

        // An "@" means they are clearly trying an email, so never answer that
        // attempt with a message about codes.
        if trimmed.contains("@") {
            let email = trimmed.lowercased()
            guard Self.isEligibleEmail(email) else { return .notRecognized }

            defaults.removeObject(forKey: Keys.code)
            defaults.set(email, forKey: Keys.email)
            revalidate()
            return .granted(label: email)
        }

        guard let match = Self.matchingCode(trimmed) else { return .notRecognized }

        if Self.isExpired(match), let expiry = match.expiryDate {
            return .expired(on: expiry)
        }

        defaults.removeObject(forKey: Keys.email)
        defaults.set(Self.normalizedCode(match.code), forKey: Keys.code)
        revalidate()
        return .granted(label: match.label)
    }

    /// Lets someone hand a device on, or move their access elsewhere.
    func revoke() {
        defaults.removeObject(forKey: Keys.code)
        defaults.removeObject(forKey: Keys.email)
        revalidate()
    }

    // MARK: - Code matching

    /// Codes get read aloud and typed on phone keyboards, so case, spaces and
    /// dashes are all ignored when matching.
    private static func normalizedCode(_ raw: String) -> String {
        raw.uppercased().filter { $0.isLetter || $0.isNumber }
    }

    private static func matchingCode(_ raw: String) -> AccessCode? {
        let normalized = normalizedCode(raw)
        guard !normalized.isEmpty else { return nil }
        return accessCodes.first { normalizedCode($0.code) == normalized }
    }

    private static func isExpired(_ code: AccessCode) -> Bool {
        guard let expiry = code.expiryDate else { return false }
        // Valid through the end of the expiry day, not from its midnight.
        let endOfDay = Calendar(identifier: .gregorian)
            .date(byAdding: .day, value: 1, to: expiry) ?? expiry
        return Date() >= endOfDay
    }

    // MARK: - Email matching

    private static func isEligibleEmail(_ email: String) -> Bool {
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

import Foundation

/// Single source of truth for the app-wide non-affiliation disclaimer.
enum LegalText {
    static let nonAffiliation = "MVM Fitness is an independent, unofficial fitness tracking tool. It is not affiliated with, endorsed by, or sponsored by the U.S. Department of War (formerly the Department of Defense), the Department of the Army, or any U.S. government agency. All standards referenced are from publicly available sources."

    static let unofficialRecords = "Records kept in this app are unofficial — official results are recorded on DA Form 705/DA 5500 and in ATIS by your unit."

    static var full: String { nonAffiliation + "\n\n" + unofficialRecords }
}
